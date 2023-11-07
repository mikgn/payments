# frozen_string_literal: true

class Merchant < User
  validates :name, presence: true
  validates :description, presence: true

  def total_transaction_sum
    transactions.where(transactions: { type: 'Charge', status: 'approved' })
                .sum('transactions.amount')
  end
end
