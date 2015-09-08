class Ticket < ActiveRecord::Base
	belongs_to :tournament
	belongs_to :summoner
	belongs_to :duo, :class_name => "Summoner", :foreign_key => "duo_id"

	validates :summoner_id, presence: true

	attr_accessor :summonerName, :duoName

	def self.new_with_summoner(ticket_params)
	    ticket = Ticket.new(ticket_params)
	    ticket.add_summoner(ticket_params[:summonerName])
	    ticket.add_duo(ticket_params[:duoName])

	    return ticket
	end

	def add_summoner(summonerName)
		summoner = Summoner.find_or_create(summonerName)
		Rails.logger.info "summoner: #{summoner.inspect}"
		self.transfer_errors(summoner)
		if !!summoner.id 
			self.summoner_id = summoner.id
		end
	end

	def add_duo(duoName)
	    if duoName.length > 1
	    	duo = Summoner.find_or_create(duoName)
	    	self.transfer_errors(duo)
	    	if !!duo.id
	      		self.duo_id = duo.id 
	    	end
	    end		
	end

	def transfer_errors(object)
		Rails.logger.info "object: #{object.inspect}"
		Rails.logger.info "errors: #{object.errors.messages}"
		if object.errors.any?
			object.errors.messages.each do |x,y|
				self.errors.add(:x, y)
			end
		end
	end


	#paypal logic doesn't belong here
	def paypal_encrypted(return_url, notify_url)
	  values = {
	    :business => Rails.application.secrets.paypal_email,
	    :cmd => '_cart',
	    :upload => 1,
	    :return => return_url,
	    :invoice => self.id,
	    :notify_url => notify_url,
	    :cert_id => Rails.application.secrets.paypal_cert_hq
	  }
	    values.merge!({
	      "amount_1" => 10,
	      "item_name_1" => 'rocks-5',
	      "item_number_1" => 1,
	      "quantity_1" => 1
	    })
	  encrypt_for_paypal(values)
	end

	PAYPAL_CERT_PEM = File.read("#{Rails.root}/certs/paypal_cert.pem")
	APP_CERT_PEM = File.read("#{Rails.root}/certs/app_cert.pem")
	APP_KEY_PEM = File.read("#{Rails.root}/certs/app_key.pem")

	def encrypt_for_paypal(values)
		signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(APP_CERT_PEM), OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
		OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
	end

	def paypal_verify
		raw_body = JSON.parse(self.notification_params.gsub("'",'"').gsub('=>',':'))
		uri = URI.parse('https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
		response = Net::HTTP.post_form(uri, raw_body)
	end
end
