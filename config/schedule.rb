# frozen_string_literal: true

set :output, 'log/cron.log'

every 1.hour do
  runner "TransactionsCleanupJob.perform_later"
end
