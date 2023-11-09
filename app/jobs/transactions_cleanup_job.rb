# frozen_string_literal: true

class TransactionsCleanupJob < ApplicationJob
  queue_as :default

  def perform
    Transaction.where(created_at: 1.hour.ago..Time.now).destroy_all
  end
end
