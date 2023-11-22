# frozen_string_literal: true

namespace :users do
  desc 'Import Users'
  task import: :environment do
    file_path = "#{Rails.root}/db/data/users.csv"

    UsersImportJob.perform_later(file_path)
  end
end
