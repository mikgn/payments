# frozen_string_literal: true

require 'csv'

module UsersImporter
  extend self

  FILE_PATH = "#{Rails.root}/db/data/users.csv".freeze

  def call
    import_users
  end

  private

  def import_users
    User.transaction do
      CSV.foreach(FILE_PATH, headers: true, header_converters: :symbol).each do |params|
        User.create!(
          name: params[:name],
          email: params[:email],
          password: params[:password],
          status: params[:status],
          description: params[:description],
          role: params[:role]
        )
      end
    end

    puts "Users have been imported"
  end
end
