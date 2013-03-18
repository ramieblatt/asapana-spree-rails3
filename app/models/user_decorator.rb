User.class_eval do 
  after_create :send_signup_confirmation
  def send_signup_confirmation
    UserMailer.signup_email(self).deliver unless self.anonymous?
  end
end 