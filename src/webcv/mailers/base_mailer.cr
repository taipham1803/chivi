require "quartz_mailer"

class BaseMailer < Quartz::Composer
  def sender
    address name: "Chivi", email: "noreply@chivi.app"
  end
end
