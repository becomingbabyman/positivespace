# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    from_id 1
    to_id 1
    from_email "MyString"
    to_email "MyString"
    body "MyText"
    embed_data "MyText"
    embed_link "MyString"
  end
end
