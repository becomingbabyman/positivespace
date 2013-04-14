class NotificationsMailer < ActionMailer::Base
  default from: "notifications@positivespace.io"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.recieved_message.subject
  #
  def recieved_message message_id
    @message = Message.find message_id
    @reply_path = "inbox?message_id=#{@message.id}"

    mail to: "#{@message.to.name} <#{@message.to.email}>", from: "#{@message.from.name} <#{@message.from.email}>", subject: "#{@message.from.name} sent you a message"
  end
end
