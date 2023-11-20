# frozen_string_literal: true

FactoryBot.define do
  factory :reversal do
    status { 'approved' }
    customer_email { 'customer@example.com' }
    customer_phone { 1_234_567_890 }
    user_id { '' }
    parent_id { '' }
  end
end
