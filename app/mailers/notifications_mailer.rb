require 'mail'
class NotificationsMailer < ActionMailer::Base
  from = Mail::Address.new "notifications@positivespace.io"
  from.display_name = "+_ Notifications"
  default css: :email, from: from.format
  layout 'email'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.recieved_message.subject
  #
  def recieved_message message_id
    @message = Message.find message_id
    @reply_path = "conversations/#{@message.conversation_id}?message_id=#{@message.id}"

    from = Mail::Address.new "notifications@positivespace.io"
    from.display_name = @message.from.name
    to = Mail::Address.new @message.to.email
    to.display_name = @message.to.name
    mail to: to.format, from: from.format, subject: "Reply to #{@message.from.name} on Positive Space"
  end

  def daily_new_messages_digest user_id
    @user = User.find user_id
    @messages = @user.recieved_messages.where("messages.created_at < ? AND messages.created_at > ?", DateTime.now, DateTime.now - 1.day).order("messages.created_at ASC")

    to = Mail::Address.new @user.email
    to.display_name = @user.name
    mail to: to.format, subject: "Today's new Positive Space messages" if @messages.any?
  end

  def weekly_new_messages_digest user_id
    @user = User.find user_id
    @messages = @user.recieved_messages.where("messages.created_at < ? AND messages.created_at > ?", DateTime.now, DateTime.now - 1.week).order("messages.created_at ASC")

    to = Mail::Address.new @user.email
    to.display_name = @user.name
    mail to: to.format, subject: "Last week's new Positive Space messages" if @messages.any?
  end
end
