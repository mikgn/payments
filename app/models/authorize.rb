# frozen_string_literal: true

class Authorize < Transaction
  validates :amount, presence: true, numericality: { greater_than: 0 }

  def cancel!
    update!(status: :reversed)
  end
end
