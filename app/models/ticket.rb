class Ticket < ActiveRecord::Base
	belongs_to :tournament
	belongs_to :summoner
	belongs_to :duo, :class_name => "Summoner", :foreign_key => "duo_id"

	attr_accessor :summonerName, :duoName

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
