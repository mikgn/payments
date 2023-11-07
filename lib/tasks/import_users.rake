# frozen_string_literal: true

namespace :users do
  desc 'Import Users'
  task import: :environment do
    UsersImporter.call
  end
end
