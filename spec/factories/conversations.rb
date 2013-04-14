# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :conversation do
    from_id 1
    to_id 1
    state "MyString"
  end
end
