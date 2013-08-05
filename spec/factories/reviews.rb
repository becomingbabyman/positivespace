# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :review do
    reviewable_id 1
    reviewable_type "MyString"
    rating 1
    vote "positive"
    user_id 1
    explanation "MyText"
  end
end
