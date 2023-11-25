# frozen_string_literal: true

RSpec.describe Api::TransactionsController, type: :controller do
  let(:merchant) { create(:merchant, email: 'mr@example.com') }
  let(:transactions) { [create(:authorize, user_id: merchant.id)] }

  before do
    user_login(merchant)
  end

  describe 'GET transactions' do
    describe 'GET collection' do
      context 'merchant transactions' do
        it 'reterns valid merchant transactions count' do
          expect(transactions.size).to eq(1)
        end

        it 'doesnt retern valid merchant transactions count' do
          expect(transactions.size).not_to eq(2)
        end
      end
    end

    describe 'GET transaction' do
      context 'with valid id' do
        it 'responds with transaction' do
          get :show, params: { id: transactions.first.id }, format: :json

          expect(response.status).to eq(200)
        end
      end

      context 'with invalid id' do
        it 'responds with an error' do
          get :show, params: { id: 'invalid-transaction-id' }, format: :json

          expect(response.status).to eq(404)
        end
      end
    end
  end

  describe 'POST transactions' do
    describe 'Create Authorize transaction' do
      let(:authorize_params) do
        {
          'type' => 'Authorize',
          'amount' => 100,
          'customer_email' => 'qwerty@qwerty.com',
          'customer_phone' => '1234567890'
        }
      end

      it 'creates authorize transaction with valid params' do
        post :create, params: { transaction: authorize_params }, format: :json

        expect(response.status).to eq(201)
        expect(
          JSON.parse(response.body).slice('type', 'amount', 'customer_email', 'customer_phone')
        ).to eq(authorize_params)
      end

      it 'doesnt create authorize transaction with invalid params' do
        post :create,
             params: { transaction: authorize_params.merge('customer_email' => 'invalid') },
             format: :json

        expect(response.status).to eq(422)
        expect(response.body).to eq('{"errors":{"customer_email":["Invalid customer email"]}}')
      end
    end

    describe 'Create Charge transaction' do
      let(:authorize) { create(:authorize, user_id: merchant.id) }
      let(:charge_params) do
        {
          'type' => 'Charge',
          'amount' => 100,
          'customer_email' => 'qwerty@qwerty.com',
          'customer_phone' => '1234567890',
          'parent_id' => authorize.id
        }
      end

      it 'creates charge transaction with valid params' do
        post :create, params: { transaction: charge_params }, format: :json

        expect(response.status).to eq(201)
        expect(
          JSON.parse(response.body).slice(
            'type', 'amount', 'customer_email', 'customer_phone', 'parent_id'
          )
        ).to eq(charge_params)
      end

      it 'doesnt create charge transaction with invalid params' do
        post :create,
             params: { transaction: charge_params.merge('amount' => 0) },
             format: :json

        expect(response.status).to eq(422)
        expect(response.body).to eq('{"errors":{"amount":["must be greater than 0"]}}')
      end
    end

    describe 'Create Refund transaction' do
      let(:charge) { create(:charge, user_id: merchant.id) }
      let(:refund_params) do
        {
          'type' => 'Refund',
          'amount' => 100,
          'customer_email' => 'qwerty@qwerty.com',
          'customer_phone' => '1234567890',
          'parent_id' => charge.id
        }
      end

      it 'creates Refund transaction and refunds Charge transaction' do
        post :create, params: { transaction: refund_params }, format: :json

        expect(response.status).to eq(201)
        expect(
          JSON.parse(response.body).slice(
            'type', 'amount', 'customer_email', 'customer_phone', 'parent_id'
          )
        ).to eq(refund_params)

        expect(JSON.parse(response.body).slice(
                 'type', 'amount', 'customer_email', 'customer_phone', 'parent_id'
               )).to eq(refund_params)
        expect(Charge.find_by(id: refund_params['parent_id']).status)
          .to eq('refunded')
      end

      it 'doesnt create Refund transaction and doesnt refunds Charge with invalid params' do
        post :create,
             params: { transaction: refund_params.merge('amount' => 0) },
             format: :json

        expect(response.status).to eq(422)
        expect(response.body).to eq('{"errors":{"amount":["must be greater than 0"]}}')
        expect(Charge.last.status).to eq('approved')
      end
    end

    describe 'Create Reversal transaction' do
      let(:authorize) { create(:authorize, user_id: merchant.id) }
      let(:reversal_params) do
        {
          'type' => 'Reversal',
          'customer_email' => 'qwerty@qwerty.com',
          'customer_phone' => '1234567890',
          'parent_id' => authorize.id
        }
      end

      it 'creates Reversal transaction and reverses Authorize transaction' do
        post :create, params: { transaction: reversal_params }, format: :json

        expect(response.status).to eq(201)
        expect(JSON.parse(response.body).slice(
                 'type', 'customer_email', 'customer_phone', 'parent_id'
               )).to eq(reversal_params)
        expect(Authorize.find_by(id: reversal_params['parent_id']).status)
          .to eq('reversed')
      end

      it 'doesnt create Reversal transaction and doesnt reverse Authorize with invalid params' do
        post :create,
             params: { transaction: reversal_params.merge('parent_id' => 'invalid') },
             format: :json

        expect(response.status).to eq(422)
        expect(response.body).to eq(
          "{\"errors\":{\"base\":[\"Invalid UUID parent_id: 'invalid'\"]}}"
        )
        expect(Authorize.last.status).to eq('approved')
      end
    end
  end
end
