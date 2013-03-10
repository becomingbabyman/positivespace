# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image do
    user_id 1
    attachable_id 1
    attachable_type "MyString"
    image "MyString"
    image_type "MyString"
    name "MyString"
    lat 1.5
    lng 1.5
  end
end
