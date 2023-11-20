# frozen_string_literal: true

class Admin::MerchantsController < ApplicationController
  before_action :set_merchant, only: %i[show edit update destroy]

  def index
    @merchants = Merchant.all.sort
  end

  def show
    merchant_transactions = @merchant.transactions
    @merchant_transactions_sum = calculate_sum(merchant_transactions)
    @merchant_transactions = merchant_transactions.group_by(&:customer_email)
  end

  def edit; end

  def update
    if @merchant.update(merchant_params)
      redirect_to merchant_path(@merchant), notice: 'Merchant was successfully updated'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @merchant.destroy

    redirect_to root_path, notice: 'Merchant was successfully destroyed'
  end

  private

  def set_merchant
    @merchant ||= Merchant.find(params[:id])
  end

  def merchant_params
    params.require(:merchant).permit(
      :name, :email, :description, :status, :password, :password_confirmation
    )
  end

  def calculate_sum(transactions)
    transactions.select { |t| t.type == 'Charge' && t.status == 'approved' }.sum(&:amount)
  end
end
