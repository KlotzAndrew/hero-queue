class PaypalApi
	PAYPAL_CERT_PEM = File.read("#{Rails.root}/certs/paypal_cert.pem")
	APP_CERT_PEM = File.read("#{Rails.root}/certs/app_cert.pem")
	APP_KEY_PEM = File.read("#{Rails.root}/certs/app_key.pem")

	def self.paypal_encrypted(ticket, return_url, notify_url)
		price = calculate_price(ticket)
		item_name = summoner_name_string(ticket) #this can be a method routing to matching game model
		
	  values = {
	    :business => Rails.application.secrets.paypal_email,
	    :cmd => '_cart',
	    :upload => 1,
	    :return => return_url,
	    :invoice => ticket.id,
	    :notify_url => notify_url + 'hook',
	    :cert_id => Rails.application.secrets.paypal_cert_hq
	  }
	    values.merge!({
	      "amount_1" => price,
	      "currency_code" => "CAD",
	      "item_name_1" => item_name,
	      "item_number_1" => 1,
	      "quantity_1" => 1,
	    })
	  encrypt_for_paypal(values)
	end

	def self.calculate_price(ticket)
		if ticket.duo
			return ticket.tournament.price.to_f*2
		else
			return ticket.tournament.price.to_f
		end
	end

	def self.summoner_name_string(ticket)
		if ticket.duo then duo = ", duo: #{ticket.duo.summonerName}" end
		duo ||= "" 
		return "HQ-ticket (#{ticket.summoner.summonerName + duo})"
	end


	def self.encrypt_for_paypal(values)
		signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(APP_CERT_PEM), OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
		OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
	end

	def self.paypal_verify(ticket)
		raw_body = JSON.parse(ticket.notification_params.gsub('\\','').gsub('=>',':'))
		uri = URI.parse('https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
		request = Net::HTTP.post_form(uri, raw_body)
	end

	def self.check_paypal_ipn(params)
		status = params[:payment_status]
	    if status == "Completed"
	    	# check reciever email is my paypal email
	    	# elsif response.body == VERIFIED or INVALID
	      ticket = Ticket.find(params[:invoice])
	      ticket.update(
	        notification_params: params, 
	        status: status, 
	        transaction_id: params[:txn_id], 
	        purchased_at: Time.now)
	      paypal_verify(ticket)
	    end
	end
end