# frozen_string_literal: true

module Api
  class TransactionsController < Api::ApplicationController
    include ActionController::MimeResponds
    before_action :authorize_request
    before_action :check_merchant_status, only: :create

    PERMITTED_PARAMS = %i[type amount customer_email customer_phone parent_id].freeze

    def index
      transactions = @current_user.transactions.group_by(&:customer_email)

      respond_to do |format|
        format.json { render json: transactions }
        format.xml { render xml: transactions.as_json }
      end
    end

    def show
      transaction = @current_user.transactions.find(params[:id])

      respond_to do |format|
        format.json { render json: transaction }
        format.xml { render xml: transaction.as_json }
      end
    end

    def create
      transaction = TransactionManager.call(transaction_params.merge(user_id: @current_user.id))

      if transaction
        respond_to do |format|
          format.json { render json: transaction, status: :created }
          format.xml { render xml: transaction.as_json, status: :created }
        end
      else
        respond_to do |format|
          format.json { render json: transaction.errors, status: :unprocessable_entity }
          format.xml { render xml: transaction.errors.as_json, status: :unprocessable_entity }
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
      Hash.from_xml(request.body.read)['root']['transaction']
          .symbolize_keys
          .slice(*PERMITTED_PARAMS)
    end
  end
end
