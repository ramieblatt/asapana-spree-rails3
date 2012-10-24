class UserMailer < ActionMailer::Base
  helper "spree/base"

  def signup_email(user)
    @user = user
    subject = "#{Spree::Config[:site_name]} #{t('subject', :scope =>'user_mailer.signup_email')}"
    mail(:to => user.email,
         :subject => subject)
  end

end
