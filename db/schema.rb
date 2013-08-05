# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130803144049) do

  create_table "achievements", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "achievements", ["name"], :name => "index_achievements_on_name"

  create_table "administrators", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "administrators", ["email"], :name => "index_administrators_on_email", :unique => true
  add_index "administrators", ["reset_password_token"], :name => "index_administrators_on_reset_password_token", :unique => true

  create_table "conversations", :force => true do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.string   "state"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "last_message_id"
    t.integer  "last_message_from_id"
    t.text     "last_message_body"
    t.text     "prompt"
    t.integer  "messages_count",       :default => 0, :null => false
    t.integer  "space_id"
    t.integer  "reviews_count",        :default => 0, :null => false
  end

  add_index "conversations", ["from_id"], :name => "index_conversations_on_from_id"
  add_index "conversations", ["last_message_from_id"], :name => "index_conversations_on_last_message_from_id"
  add_index "conversations", ["last_message_id"], :name => "index_conversations_on_last_message_id"
  add_index "conversations", ["messages_count"], :name => "index_conversations_on_messages_count"
  add_index "conversations", ["prompt"], :name => "index_conversations_on_prompt"
  add_index "conversations", ["reviews_count"], :name => "index_conversations_on_reviews_count"
  add_index "conversations", ["space_id"], :name => "index_conversations_on_space_id"
  add_index "conversations", ["state"], :name => "index_conversations_on_state"
  add_index "conversations", ["to_id"], :name => "index_conversations_on_to_id"

  create_table "emails", :force => true do |t|
    t.string   "state"
    t.string   "action"
    t.text     "rejection_message",  :default => ""
    t.text     "error_messages",     :default => "--- []\n"
    t.string   "recipient"
    t.string   "sender"
    t.string   "from"
    t.string   "subject"
    t.text     "body_plain"
    t.text     "stripped_text"
    t.text     "stripped_signature"
    t.text     "body_html"
    t.text     "stripped_html"
    t.integer  "attachment_count"
    t.integer  "timestamp"
    t.string   "token"
    t.string   "signature"
    t.text     "message_headers"
    t.text     "content_id_map"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "emails", ["action"], :name => "index_emails_on_action"
  add_index "emails", ["from"], :name => "index_emails_on_from"
  add_index "emails", ["recipient"], :name => "index_emails_on_recipient"
  add_index "emails", ["sender"], :name => "index_emails_on_sender"
  add_index "emails", ["signature"], :name => "index_emails_on_signature"
  add_index "emails", ["state"], :name => "index_emails_on_state"
  add_index "emails", ["subject"], :name => "index_emails_on_subject"
  add_index "emails", ["token"], :name => "index_emails_on_token"

  create_table "follows", :force => true do |t|
    t.string   "follower_type"
    t.integer  "follower_id"
    t.string   "followable_type"
    t.integer  "followable_id"
    t.datetime "created_at"
  end

  add_index "follows", ["followable_id", "followable_type"], :name => "fk_followables"
  add_index "follows", ["follower_id", "follower_type"], :name => "fk_follows"

  create_table "images", :force => true do |t|
    t.integer  "user_id"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "image"
    t.string   "image_type"
    t.string   "name"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "images", ["attachable_id", "attachable_type"], :name => "index_images_on_attachable_id_and_attachable_type"
  add_index "images", ["attachable_id"], :name => "index_images_on_attachable_id"
  add_index "images", ["attachable_type"], :name => "index_images_on_attachable_type"
  add_index "images", ["user_id"], :name => "index_images_on_user_id"

  create_table "impressions", :force => true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], :name => "controlleraction_ip_index"
  add_index "impressions", ["controller_name", "action_name", "request_hash"], :name => "controlleraction_request_index"
  add_index "impressions", ["controller_name", "action_name", "session_hash"], :name => "controlleraction_session_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], :name => "poly_ip_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], :name => "poly_request_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], :name => "poly_session_index"
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], :name => "impressionable_type_message_index"
  add_index "impressions", ["user_id"], :name => "index_impressions_on_user_id"

  create_table "invitations", :force => true do |t|
    t.integer  "user_id"
    t.string   "code"
    t.integer  "max_use_count",     :default => 1
    t.integer  "current_use_count", :default => 0
    t.integer  "share_count",       :default => 0
    t.integer  "impressions_count", :default => 0
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "invitations", ["code"], :name => "index_invitations_on_code"
  add_index "invitations", ["user_id"], :name => "index_invitations_on_user_id"

  create_table "likes", :force => true do |t|
    t.string   "liker_type"
    t.integer  "liker_id"
    t.string   "likeable_type"
    t.integer  "likeable_id"
    t.datetime "created_at"
  end

  add_index "likes", ["likeable_id", "likeable_type"], :name => "fk_likeables"
  add_index "likes", ["liker_id", "liker_type"], :name => "fk_likes"

  create_table "magnetisms", :force => true do |t|
    t.integer  "inc"
    t.string   "reason"
    t.text     "note"
    t.integer  "user_id"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "magnetisms", ["attachable_id"], :name => "index_magnetisms_on_attachable_id"
  add_index "magnetisms", ["attachable_type"], :name => "index_magnetisms_on_attachable_type"
  add_index "magnetisms", ["inc"], :name => "index_magnetisms_on_inc"
  add_index "magnetisms", ["reason"], :name => "index_magnetisms_on_reason"
  add_index "magnetisms", ["user_id"], :name => "index_magnetisms_on_user_id"

  create_table "mentions", :force => true do |t|
    t.string   "mentioner_type"
    t.integer  "mentioner_id"
    t.string   "mentionable_type"
    t.integer  "mentionable_id"
    t.datetime "created_at"
  end

  add_index "mentions", ["mentionable_id", "mentionable_type"], :name => "fk_mentionables"
  add_index "mentions", ["mentioner_id", "mentioner_type"], :name => "fk_mentions"

  create_table "messages", :force => true do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.string   "from_email"
    t.string   "to_email"
    t.string   "embed_url"
    t.text     "embed_data"
    t.text     "body"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "session_id"
    t.string   "state"
    t.integer  "conversation_id"
    t.string   "authentication_token"
  end

  add_index "messages", ["conversation_id"], :name => "index_messages_on_conversation_id"
  add_index "messages", ["from_email"], :name => "index_messages_on_from_email"
  add_index "messages", ["from_id", "to_id"], :name => "index_messages_on_from_id_and_to_id"
  add_index "messages", ["from_id"], :name => "index_messages_on_from_id"
  add_index "messages", ["session_id"], :name => "index_messages_on_session_id"
  add_index "messages", ["state"], :name => "index_messages_on_state"
  add_index "messages", ["to_email"], :name => "index_messages_on_to_email"
  add_index "messages", ["to_id"], :name => "index_messages_on_to_id"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "reviews", :force => true do |t|
    t.integer  "reviewable_id",   :null => false
    t.string   "reviewable_type", :null => false
    t.integer  "rating"
    t.string   "vote"
    t.integer  "user_id",         :null => false
    t.text     "explanation"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "reviews", ["rating"], :name => "index_reviews_on_rating"
  add_index "reviews", ["reviewable_id", "reviewable_type"], :name => "index_reviews_on_reviewable_id_and_reviewable_type"
  add_index "reviews", ["reviewable_id"], :name => "index_reviews_on_reviewable_id"
  add_index "reviews", ["reviewable_type"], :name => "index_reviews_on_reviewable_type"
  add_index "reviews", ["user_id"], :name => "index_reviews_on_user_id"
  add_index "reviews", ["vote"], :name => "index_reviews_on_vote"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shortened_urls", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type", :limit => 20
    t.string   "url",                                     :null => false
    t.string   "unique_key", :limit => 10,                :null => false
    t.integer  "use_count",                :default => 0, :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "shortened_urls", ["owner_id", "owner_type"], :name => "index_shortened_urls_on_owner_id_and_owner_type"
  add_index "shortened_urls", ["unique_key"], :name => "index_shortened_urls_on_unique_key", :unique => true
  add_index "shortened_urls", ["url"], :name => "index_shortened_urls_on_url"

  create_table "spaces", :force => true do |t|
    t.integer  "user_id"
    t.text     "prompt"
    t.text     "state"
    t.text     "embed_url"
    t.text     "embed_data"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "conversations_count", :default => 0, :null => false
  end

  add_index "spaces", ["conversations_count"], :name => "index_spaces_on_conversations_count"
  add_index "spaces", ["embed_url"], :name => "index_spaces_on_embed_url"
  add_index "spaces", ["prompt"], :name => "index_spaces_on_prompt"
  add_index "spaces", ["state"], :name => "index_spaces_on_state"
  add_index "spaces", ["user_id"], :name => "index_spaces_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                        :default => "",         :null => false
    t.string   "encrypted_password",           :default => "",         :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",              :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.integer  "permissions",                  :default => 0
    t.string   "facebook_id"
    t.string   "username"
    t.string   "slug"
    t.string   "acq_source"
    t.string   "acq_medium"
    t.string   "name"
    t.text     "body"
    t.string   "location"
    t.string   "personal_url"
    t.text     "positive_response"
    t.text     "negative_response"
    t.string   "gender"
    t.datetime "birthday"
    t.string   "locale"
    t.integer  "timezone"
    t.integer  "impressions_count",            :default => 1
    t.integer  "invitation_id"
    t.string   "state"
    t.integer  "followers_count",              :default => 0
    t.integer  "likers_count",                 :default => 0
    t.integer  "mentioners_count",             :default => 0
    t.integer  "remaining_invitations_count",  :default => 0
    t.text     "settings",                     :default => "--- {}\n"
    t.text     "bio"
    t.integer  "magnetism",                    :default => 0
    t.integer  "magnetisms_count",             :default => 0
    t.integer  "achievements_count",           :default => 0
    t.integer  "follows_count",                :default => 0,          :null => false
    t.integer  "sent_conversations_count",     :default => 0,          :null => false
    t.integer  "recieved_conversations_count", :default => 0,          :null => false
    t.integer  "sent_messages_count",          :default => 0,          :null => false
    t.integer  "recieved_messages_count",      :default => 0,          :null => false
    t.integer  "spaces_count",                 :default => 0,          :null => false
    t.integer  "reviewed_count",               :default => 0,          :null => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id"
  add_index "users", ["followers_count"], :name => "index_users_on_followers_count"
  add_index "users", ["follows_count"], :name => "index_users_on_follows_count"
  add_index "users", ["impressions_count"], :name => "index_users_on_impressions_count"
  add_index "users", ["likers_count"], :name => "index_users_on_likers_count"
  add_index "users", ["location"], :name => "index_users_on_location"
  add_index "users", ["magnetism"], :name => "index_users_on_magnetism"
  add_index "users", ["mentioners_count"], :name => "index_users_on_mentioners_count"
  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["permissions"], :name => "index_users_on_permissions"
  add_index "users", ["recieved_conversations_count"], :name => "index_users_on_recieved_conversations_count"
  add_index "users", ["recieved_messages_count"], :name => "index_users_on_recieved_messages_count"
  add_index "users", ["remaining_invitations_count"], :name => "index_users_on_remaining_invitations_count"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["reviewed_count"], :name => "index_users_on_reviewed_count"
  add_index "users", ["sent_conversations_count"], :name => "index_users_on_sent_conversations_count"
  add_index "users", ["sent_messages_count"], :name => "index_users_on_sent_messages_count"
  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true
  add_index "users", ["spaces_count"], :name => "index_users_on_spaces_count"
  add_index "users", ["state"], :name => "index_users_on_state"
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "wins", :force => true do |t|
    t.integer  "achievement_id"
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "wins", ["achievement_id", "user_id"], :name => "index_wins_on_achievement_id_and_user_id"
  add_index "wins", ["achievement_id"], :name => "index_wins_on_achievement_id"
  add_index "wins", ["user_id"], :name => "index_wins_on_user_id"

end
