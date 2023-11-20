# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    name { 'Admin1' }
    status { 'active' }
    email { 'admin@example.com' }
    password { 'Adminpass1' }
  end
end
