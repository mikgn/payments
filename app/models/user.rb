# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  self.inheritance_column = 'role'

  EMAIL_FORMAT = /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/

  enum status: {
    inactive: 0,
    active: 1
  }

  has_many :transactions, dependent: :restrict_with_error

  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :email, presence: true, uniqueness: true, format: { with: EMAIL_FORMAT }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
