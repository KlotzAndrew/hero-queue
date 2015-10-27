class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@heroqueue.com"
  layout 'mailer'
end
