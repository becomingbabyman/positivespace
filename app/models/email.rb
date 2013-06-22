class Email < ActiveRecord::Base
	state_machine :initial => :pending do
		event :process do
			transition :pending => :processing
		end
		after_transition on: :process, do: :start_processing

		event :resolve do
			transition :processing => :resolved
		end

		event :reject do
			transition :processing => :rejected
		end
		after_transition on: :reject, do: :notify_sender_of_rejection
	end

	serialize :error_messages

	attr_accessible :action, :attachment_count, :body_html, :body_plain, :content_id_map, :from, :message_headers, :recipient, :sender, :signature, :stripped_html, :stripped_signature, :stripped_text, :subject, :timestamp, :token

	def self.process email_id
		email = Email.find(email_id)
		email.process
	end

private

	def start_processing
		if self.send("process_#{self.action}")
			self.resolve
		else
			self.reject
		end
	end

	def process_message
		attrs = self.recipient.split("@")[0].split("_")

		self.error_messages << "invalid reply to email address" unless m_id = attrs[-2].try(:to_i) and m_auth_token = attrs[-1]
		self.error_messages << "could not find a message to reply to" unless m_id and message = Message.find(m_id)
		if message
			self.error_messages << "authorization token is invalid" unless message.authentication_token == m_auth_token
			# TODO: This does not work when you forward your email to another address. Think about alternatives.
			# self.error_messages << "your email address is not authorized to reply to this message" unless message.to.email == sender
			self.error_messages << "this message has already been replied to" unless message.conversation.last_message_id == message.id
			self.error_messages << "reply is too long, it contained #{self.stripped_text.size} characters but #{message.max_char_count} characters is the max" if self.stripped_text.size > (message.max_char_count + Message::CHAR_COUNT_PADDING)
		end

		if self.error_messages.any?
			self.rejection_message = "Sorry, your message could not be saved. If you want to try again, please make sure to reply from the same email address the original message was sent to."
			new_message = false
		else
			new_message = message.email_reply(self.stripped_text, m_auth_token)
		end

		self.save

		new_message
	end

	def notify_sender_of_rejection
		# NotificaitonsMailer.email_recected(self.id)
		# TODO: in the email say "DO NOT REPLY TO THIS EMAIL"
	end

end
