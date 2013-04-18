class NotificationsMailer < ActionMailer::Base
  default from: "notifications@positivespace.io"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.recieved_message.subject
  #
  def recieved_message message_id
    @message = Message.find message_id
    @reply_path = "conversations/#{@message.conversation_id}?message_id=#{@message.id}"

    mail to: "#{@message.to.name} <#{@message.to.email}>", from: "#{@message.from.name} <notifications@positivespace.io>", subject: "Reply to #{@message.from.name}"
  end
end
