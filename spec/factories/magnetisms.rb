# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :magnetism do
    inc 1
    reason "MyString"
    note "MyText"
    user_id 1
    attachable_id 1
    attachable_type "MyString"
  end
end
