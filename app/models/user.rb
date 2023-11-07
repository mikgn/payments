# frozen_string_literal: true

class User < ApplicationRecord
  self.inheritance_column = 'role'

  EMAIL_FORMAT = /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/

  enum status: {
    inactive: 0,
    active: 1
  }

  has_many :transactions

  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: EMAIL_FORMAT }
  def admin?
    role == 'Admin'
  end
end
