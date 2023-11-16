# frozen_string_literal: true

module TransactionManager
  extend self

  TRANSACTIONS_DEPENDENCIES = {
    'Refund' => 'Charge',
    'Reversal' => 'Authorize',
    'Charge' => 'Authorize'
  }.freeze

  STATUSES_FOR_REFERENCE = %w[
    approved
    refunded
  ].freeze

  def call(params)
    new_transaction = params[:type].constantize.new(params)

    if must_have_parent?(new_transaction)
      process_with_transaction(new_transaction)
    else
      new_transaction.save!
    end

    new_transaction
  end

  private

  def process_with_transaction(new_transaction)
    ActiveRecord::Base.transaction do
      parent_transaction = fetch_parent_transaction(new_transaction)

      if can_be_referenced?(parent_transaction)
        parent_transaction.cancel! unless new_transaction.is_a?(Charge)
      else
        invalid_transaction!(new_transaction)
      end

      new_transaction.save!
    end
  end

  def must_have_parent?(transaction)
    TRANSACTIONS_DEPENDENCIES.keys.include?(transaction.type)
  end

  def can_be_referenced?(transaction)
    STATUSES_FOR_REFERENCE.include?(transaction.status)
  end

  def fetch_parent_transaction(transaction)
    TRANSACTIONS_DEPENDENCIES[transaction.type].constantize.find(transaction.parent_id)
  end

  def invalid_transaction!(transaction)
    transaction.status = :error
    transaction.parent_id = nil
  end
end
