# frozen_string_literal: true

class Merchant < User
  validates :name, presence: true

  def total_transaction_sum
    transactions.where(transactions: { type: 'Charge', status: 'approved' })
                .sum('transactions.amount')
  end

  def total_transactions
    transactions.size
  end
end
