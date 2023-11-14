# frozen_string_literal: true

class Charge < Transaction
  validates :amount, presence: true, numericality: { greater_than: 0 }

  def cancel!
    update!(status: :refunded)
  end
end
