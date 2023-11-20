# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    name { 'Merchant1' }
    status { 'active' }
    email { 'merchant@example.com' }
    password { 'Merchantpass1' }
  end
end
