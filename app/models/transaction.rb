# frozen_string_literal: true

class Transaction < ApplicationRecord
  enum status: {
    approved: 0,
    reversed: 1,
    refunded: 2,
    error: 3
  }

  belongs_to :user

  validates :parent_id, presence: true, allow_nil: true
  validates :status, presence: true, inclusion: { in: statuses.keys }, allow_nil: true
  validates :customer_email, presence: true, format: { with: User::EMAIL_FORMAT }
  validates :customer_phone, numericality: true,
                             length: { minimum: 10, maximum: 15 },
                             allow_nil: true

  def cancel!
    raise NotImplementedError
  end

  def serializable_hash(options = nil)
    super.merge(type: type)
  end
end
