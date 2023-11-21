# frozen_string_literal: true

class Admin::TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[show]

  def index
    transactions =
      if params[:merchant_id].present?
        Transaction.where(user_id: params[:merchant_id]).group(:type, 'transactions.id')
      else
        Transaction.group(:customer_email, :type, 'transactions.id')
      end

    @transactions = transactions.order(created_at: :desc)
  end

  def show; end

  private

  def set_transaction
    @transaction ||= Transaction.find(params[:id])
  end
end
