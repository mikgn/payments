# frozen_string_literal: true

class Transaction < ApplicationRecord
  enum status: {
    approved: 0,
    reversed: 1,
    refunded: 2,
    error: 3
  }

  belongs_to :user

  validates :amount, presence: true,
                     numericality: { greater_than: 0 },
                     unless: -> { type == 'Reversal' }
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :customer_email, presence: true,
                             format: { with: User::EMAIL_FORMAT }
end
