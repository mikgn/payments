# frozen_string_literal: true

class Admin::MerchantsController < ApplicationController
  before_action :set_merchant, only: %i[show edit update destroy]

  def index
    @merchants = Merchant.all.sort
  end

  def show; end

  def edit; end

  def update
    if @merchant.update(merchant_params)
      redirect_to admin_merchant_path(@merchant), notice: 'Merchant was successfully updated'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @merchant.destroy
      redirect_to root_path, notice: 'Merchant was successfully destroyed'
    else
      render 'admin/merchants/edit', status: :unprocessable_entity
    end
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
end
