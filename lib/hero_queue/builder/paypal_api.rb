module Builder
	class PaypalApi
		PAYPAL_CERT_PEM = File.read("#{Rails.root}/certs/paypal_cert.pem")
		APP_CERT_PEM = File.read("#{Rails.root}/certs/app_cert.pem")
		APP_KEY_PEM = File.read("#{Rails.root}/certs/app_key.pem")

		def self.paypal_encrypted(ticket, return_url, notify_url)
			values = build_values(ticket, return_url, notify_url)
			encrypt_for_paypal(values)
		end

		private

		def self.build_values(ticket, return_url, notify_url)
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
		      "amount_1" => calculate_price(ticket),
		      "currency_code" => "CAD",
		      "item_name_1" => "#{ticket_name(ticket)}: #{summoner_name_string(ticket)}",
		      "item_number_1" => 1,
		      "quantity_1" => 1,
		    })
		    return values
		end

		def self.calculate_price(ticket)
			if ticket.duo
				return ticket.tournament.price.to_f*2
			else
				return ticket.tournament.price.to_f
			end
		end

		def self.ticket_name(ticket)
			"HQ-#{ticket.tournament.start_date.strftime("%b. %d")}"
		end

		def self.summoner_name_string(ticket)
			if ticket.duo then duo = ", duo: #{ticket.duo.summonerName}" end
			duo ||= "" 
			return "(#{ticket.summoner.summonerName + duo})"
		end

		def self.encrypt_for_paypal(values)
			signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(APP_CERT_PEM), OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
			OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
		end
	end
end