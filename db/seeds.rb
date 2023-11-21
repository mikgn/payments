# frozen_string_literal: true

Admin.create!(
  name: 'admin',
  email: 'admin@example.com',
  status: 1,
  password: 'Adminpass',
  password_confirmation: 'Adminpass'

)

puts
puts 'Admin created'

5.times do |i|
  Merchant.create!(
    name: "test_merchant#{i}",
    email: "test_merchant#{i}@example.com",
    description: "test_merchant#{i} description",
    status: [0, 1].sample,
    password: "Testpass#{i}",
    password_confirmation: "Testpass#{i}"
  )
end

puts 'Merchants created'

merchants = Merchant.all

5.times do |i|
  merchants.each do |merchant|
    amount = rand(10..100)
    status = 0
    customer_email = "#{merchant.name}#{i}@example.com"
    customer_phone = rand(1111111111..9999999999)
    user_id = merchant.id

    authorize = Authorize.create!(
      amount:,
      status:,
      customer_email:,
      customer_phone:,
      user_id:
    )

    parent_id = authorize.id

    charge = Charge.create!(
      amount:,
      status:,
      customer_email:,
      customer_phone:,
      user_id:,
      parent_id:
    )
  end
end

puts 'Approved transactions created'

2.times do |i|
  merchants.each do |merchant|
    amount = rand(10..100)
    status = 0
    customer_email = "#{merchant.name}#{i}@example.com"
    customer_phone = rand(1111111111..9999999999)
    user_id = merchant.id

    authorize = Authorize.create!(
      amount:,
      status:,
      customer_email:,
      customer_phone:,
      user_id:
    )

    parent_id = authorize.id

    charge = Reversal.create!(
      status:,
      customer_email:,
      customer_phone:,
      user_id:,
      parent_id:
    )
  end
end

puts 'Reversed transactions created'

2.times do |i|
  merchants.each do |merchant|
    amount = rand(10..100)
    status = 0
    customer_email = "#{merchant.name}#{i}@example.com"
    customer_phone = rand(1111111111..9999999999)
    user_id = merchant.id

    authorize = Authorize.create!(
      amount:,
      status:,
      customer_email:,
      customer_phone:,
      user_id:
    )

    parent_id = authorize.id

    charge = Charge.create!(
      amount:,
      status:,
      customer_email:,
      customer_phone:,
      user_id:,
      parent_id:
    )

    parent_id = charge.id

    charge = Refund.create!(
      amount:,
      status:,
      customer_email:,
      customer_phone:,
      user_id:,
      parent_id:
    )
  end
end

puts 'Refunded transactions created'
