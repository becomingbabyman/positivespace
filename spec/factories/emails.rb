# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email do
    recipient "MyString"
    sender "MyString"
    from "MyString"
    subject "MyString"
    body_plain "MyText"
    stripped_text "MyText"
    stripped_signature "MyText"
    body_html "MyText"
    stripped_html "MyText"
    attachment_count 1
    timestamp 1
    token "MyString"
    signature "MyString"
    message_headers "MyText"
    content_id_map "MyText"
  end
end
