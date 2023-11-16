# frozen_string_literal: true

module Api
  class TransactionsController < Api::ApplicationController
    include ActionController::MimeResponds

    before_action :authorize_request
    before_action :check_merchant_status, only: :create
    before_action :validate_params, only: :create

    PERMITTED_PARAMS = %i[type amount customer_email customer_phone parent_id].freeze

    def index
      transactions = @current_user.transactions.group_by(&:customer_email)

      respond_to do |format|
        format.json do
          render json: transactions
        end
        format.xml do
          render xml: transactions.as_json
        end
      end
    end

    def show
      transaction = @current_user.transactions.find(params[:id])

      respond_to do |format|
        format.json do
          render json: transaction
        end
        format.xml do
          render xml: transaction.as_json
        end
      end
    end

    def create
      transaction = TransactionManager.call(transaction_params.merge(user_id: @current_user.id))

      if transaction
        respond_to do |format|
          format.json do
            render json: transaction, status: :created
          end
          format.xml do
            render xml: transaction.as_json, status: :created
          end
        end
      else
        respond_to do |format|
          format.json do
            render json: { errors: transaction.errors }, status: :unprocessable_entity
          end
          format.xml do
            render xml: { errors: transaction.errors.as_json }, status: :unprocessable_entity
          end
        end
      end
    end

    private

    def transaction_params
      if request.format.xml?
        fetch_xml_params
      elsif request.format.json?
        fetch_json_params
      else
        raise ActionController::UnknownFormat
      end
    end

    def fetch_json_params
      params.require(:transaction).permit(*PERMITTED_PARAMS)
    end

    def fetch_xml_params
      Hash.from_xml(request.raw_post)['transaction'].symbolize_keys.slice(*PERMITTED_PARAMS)
    end

    def validate_params
      validator = TransactionParamsValidator.new(transaction_params)

      return if validator.valid?

      respond_to do |format|
        format.json do
          render json: { errors: validator.errors }, status: :unprocessable_entity
        end
        format.xml do
          render xml: { errors: validator.errors.as_json }, status: :unprocessable_entity
        end
      end
    end
  end
end
