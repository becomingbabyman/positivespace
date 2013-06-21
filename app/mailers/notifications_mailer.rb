require 'mail'
class NotificationsMailer < ActionMailer::Base
  from = Mail::Address.new "notifications@positivespace.io"
  from.display_name = "+_ Notifications"
  default css: :email, from: from.format
  layout 'email'
  EMAIl_CHARS = "^a-zA-Z0-9!#\$%&@'*+-/=?^_`{|}~.]+"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.recieved_message.subject
  #
  def recieved_message message_id
    @message = Message.find message_id
    @reply_path = "conversations/#{@message.conversation_id}?message_id=#{@message.id}"

    from = Mail::Address.new "notifications@positivespace.io"
    from.display_name = @message.from.name.tr(EMAIl_CHARS, '')
    to = Mail::Address.new @message.to.email
    to.display_name = @message.to.name.tr(EMAIl_CHARS, '')
    mail to: to.format, from: from.format, subject: "Reply to #{@message.from.name} on Positive Space"
  end

  def daily_new_messages_digest user_id
    @user = User.find user_id
    @messages = @user.recieved_messages.where("messages.created_at < ? AND messages.created_at > ?", DateTime.now, DateTime.now - 1.day).order("messages.created_at ASC")

    to = Mail::Address.new @user.email
    to.display_name = @user.name.tr(EMAIl_CHARS, '')
    mail to: to.format, subject: "Today's new Positive Space messages" if @messages.any?
  end

  def weekly_new_messages_digest user_id
    @user = User.find user_id
    @messages = @user.recieved_messages.where("messages.created_at < ? AND messages.created_at > ?", DateTime.now, DateTime.now - 1.week).order("messages.created_at ASC")

    to = Mail::Address.new @user.email
    to.display_name = @user.name.tr(EMAIl_CHARS, '')
    mail to: to.format, subject: "Last week's new Positive Space messages" if @messages.any?
  end

  def daily_pending_messages_reminder user_id
    @user = User.find user_id
    @conversations = @user.conversations.in_progress.turn(@user.id).order("conversations.updated_at ASC")

    to = Mail::Address.new @user.email
    to.display_name = @user.name.tr(EMAIl_CHARS, '')
    mail to: to.format, subject: "Conversations awaiting your reply on Positive Space" if @conversations.any?
  end

  def weekly_pending_messages_reminder user_id
    @user = User.find user_id
    @conversations = @user.conversations.in_progress.turn(@user.id).order("conversations.updated_at ASC")

    to = Mail::Address.new @user.email
    to.display_name = @user.name.tr(EMAIl_CHARS, '')
    mail to: to.format, subject: "Conversations awaiting your reply on Positive Space" if @conversations.any?
  end

  def new_followers user_id
    @user = User.find user_id
    @follows = Follow.where { (followable_type == 'User') & (followable_id == user_id) & (created_at < DateTime.now) & (created_at > DateTime.now - 1.week) }

    to = Mail::Address.new @user.email
    to.display_name = @user.name.tr(EMAIl_CHARS, '')
    mail to: to.format, subject: "You have new followers on Positive Space" if @follows.any?
  end
end
