object @message

extends 'api/v1/messages/base'

attributes :from_email

child conversation: :conversation do
	extends 'api/v1/conversations/base'
end
