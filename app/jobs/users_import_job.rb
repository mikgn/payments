# frozen_string_literal: true

require 'csv'

class UsersImportJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: 1

  def perform(file_path)
    CSV.foreach(file_path, headers: true, header_converters: :symbol).each do |params|
      User.create!(
        name: params[:name],
        email: params[:email],
        password: params[:password],
        status: params[:status],
        description: params[:description],
        role: params[:role]
      )
    end

    puts "#{self.class.name}: Users have been imported"
  end
end
