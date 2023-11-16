# frozen_string_literal: true

class TransactionParamsValidator
  include ActiveModel::Validations

  TRANSACTION_TYPES = %w[Authorize Charge Reversal Refund].freeze
  UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  def initialize(data)
    @type = data[:type]
    @amount = data[:amount]
    @parent_id = data[:parent_id]
    @customer_email = data[:customer_email]
    @customer_phone = data[:customer_phone]
  end

  validates :type, inclusion: { in: TRANSACTION_TYPES, message: 'Invalid transaction type' }
  validates :amount, presence: true,
                     numericality: { greater_than: 0 },
                     unless: -> { type == 'Reversal' }
  validate :validate_uuid_format
  validates :customer_email, presence: true,
                             format: { with: User::EMAIL_FORMAT, message: 'Invalid customer email' }
  validates :customer_phone, numericality: true, length: { minimum: 10, maximum: 15 }

  private

  attr_reader :type, :amount, :parent_id, :customer_email, :customer_phone

  def validate_uuid_format
    return true if parent_id.nil? && type == 'Authorize'

    return true if UUID_REGEX.match?(parent_id&.downcase)

    errors.add(:base, "Invalid UUID parent_id: '#{parent_id}'")
  end
end
