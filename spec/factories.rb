# Read about factories at https://github.com/thoughtbot/factory_girl
require 'action_dispatch/testing/test_process'
include ActionDispatch::TestProcess

FactoryGirl.define do
    sequence :email do |n|
        "p#{n}-#{Faker::Internet.user_name}@example.com"
    end
    sequence :name do |n|
        "#{Faker::Name.name} #{n}"
    end
    sequence :username do |n|
        "#{Faker::Internet.user_name.gsub(/_|\./, '-')}#{n}"[0..20]
    end
    sequence :company do |n|
        "#{Faker::Company.name} #{n}"
    end
    sequence :bs do |n|
        "#{Faker::Company.bs} #{n}"
    end
    sequence :catch_phrase do |n|
        "#{Faker::Company.catch_phrase} #{n}"
    end
    sequence :paragraph do |n|
        "#{Faker::Lorem.paragraph} #{n}"
    end
    sequence :price do |n|
        (100000.0/rand(1000)).round(2)
    end
    sequence :url do |n|
        "#{Faker::Internet.url}#{n}"
    end
    sequence :question do |n|
        "What is the meaning of #{n}?"
    end

    factory :user do
        name { generate :name }
        email { generate :email }
        username { generate :username }
        password '12345678'
        personal_url { generate :url }
        location { Faker::Address.city }
        bio { generate :paragraph }
        after(:create) { |u| FactoryGirl.create(:space, user_id: u.id) }
    end

    factory :space do
        prompt { generate :paragraph }
    end

end
