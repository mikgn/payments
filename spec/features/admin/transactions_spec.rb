# frozen_string_literal: true

RSpec.describe Admin::TransactionsController, type: :feature do
  describe 'Admin Transactions' do
    let(:username) { 'admin' }
    let(:password) { 'Adminpass' }
    let!(:non_existent_email) { 'non_existent@example.com' }
    let!(:merchant) { create(:merchant) }
    let!(:other_merchant) { create(:merchant, email: 'other_merchant@example.com') }
    let(:merchant_transaction) { create(:authorize, user_id: merchant.id) }
    let!(:merchant_transaction_values) { merchant_transaction.attributes.values.compact }
    let!(:other_transactions) do
      create_list(
        :authorize,
        3,
        user_id: other_merchant.id,
        customer_email: 'other_customer_@example.com'
      )
    end

    before do
      http_login(username, password)
    end

    describe 'GET #index' do
      it 'displays a list of transactions' do
        visit admin_transactions_path

        other_transactions.each do |transaction|
          transaction.attributes.values.compact.each do |attr|
            expect(page).to have_content(attr)
          end
        end

        merchant_transaction_values.each do |attr|
          expect(page).to have_content(attr)
        end
      end

      it 'filters transactions by merchant_id' do
        visit admin_transactions_path(merchant_id: merchant.id)

        merchant_transaction_values.each do |attr|
          expect(page).to have_content(attr)
        end

        expect(page).not_to have_content(other_transactions.first.customer_email)
      end
    end

    describe 'GET #show' do
      it 'displays transaction' do
        visit admin_transaction_path(merchant_transaction)

        merchant_transaction_values.each do |attr|
          expect(page).to have_content(attr)
        end

        expect(page).not_to have_content(other_transactions.first.customer_email)
      end
    end
  end
end
