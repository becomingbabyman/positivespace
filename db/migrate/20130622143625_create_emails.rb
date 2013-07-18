class CreateEmails < ActiveRecord::Migration
	def change
		create_table :emails do |t|
			t.string :state
			t.string :action
			t.text :rejection_message, default: ''
			t.text :error_messages, default: []

			t.string :recipient
			t.string :sender
			t.string :from
			t.string :subject
			t.text :body_plain
			t.text :stripped_text
			t.text :stripped_signature
			t.text :body_html
			t.text :stripped_html
			t.integer :attachment_count
			t.integer :timestamp
			t.string :token
			t.string :signature
			t.text :message_headers
			t.text :content_id_map

			t.timestamps
		end
		add_index :emails, :state
		add_index :emails, :action

		add_index :emails, :recipient
		add_index :emails, :sender
		add_index :emails, :from
		add_index :emails, :subject
		add_index :emails, :token
		add_index :emails, :signature

		add_column :messages, :authentication_token, :string

		# Message.reset_column_information

		# say_with_time "Add auth token to all messages" do
		#	Message.all.each do |msg|
		#		msg.authentication_token = SecureRandom.hex(20)
		#		msg.save(:validate=>false)
		#	end
		# end
	end
end
