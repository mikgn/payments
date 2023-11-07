# frozen_string_literal: true

every 1.hour do
  runner "TransactionsCleanupJob.perform_later"
end
