# frozen_string_literal: true

RSpec.describe Api::TransactionsController, type: :controller do
  let(:merchant) { create(:merchant) }

  before do
    user_login(merchant)
  end

  describe 'GET transactions' do
    let(:transactions) { [create(:authorize, user_id: merchant.id)] }

    describe 'GET collection' do
      context 'merchant transactions' do
        it 'returns valid merchant transactions count' do
          expect(transactions.size).to eq(1)
        end

        it 'does not return valid merchant transactions count' do
          expect(transactions.size).not_to eq(2)
        end
      end
    end

    describe 'GET transaction' do
      context 'with valid id' do
        it 'responds with transaction in XML format' do
          get :show, params: { id: transactions.first.id, format: :xml }

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/xml; charset=utf-8')
        end
      end

      context 'with invalid id' do
        it 'responds with an error in XML format' do
          get :show, params: { id: 'invalid-transaction-id', format: :xml }

          expect(response.status).to eq(404)
          expect(response.content_type).to eq('application/xml; charset=utf-8')
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
          'customer_phone' => 1_234_567_890
        }
      end
      let(:valid_authorize_params) do
        { 'transaction' => authorize_params }.to_xml
      end
      let(:invalid_authorize_params) do
        { 'transaction' => authorize_params.merge('customer_email' => 'invalid') }.to_xml
      end
      let(:response_body) do
        <<-XML
          <?xml version="1.0" encoding="UTF-8"?>
            <hash>
              <errors>
                <customer-email type="array">
                  <customer-email>Invalid customer email</customer-email>
                </customer-email>
              </errors>
            </hash>
        XML
      end

      it 'creates authorize transaction with valid params in XML format' do
        post :create, body: valid_authorize_params, format: :xml

        expect(response.status).to eq(201)
        expect(response.content_type).to eq('application/xml; charset=utf-8')
      end

      it 'does not create authorize transaction with invalid params in XML format' do
        post :create, body: invalid_authorize_params, format: :xml

        expect(response.status).to eq(422)
        expect(response.content_type).to eq('application/xml; charset=utf-8')
        expect(response.body.squish).to eq(response_body.squish)
      end
    end

    describe 'Create Charge transaction' do
      let(:authorize) { create(:authorize, user_id: merchant.id) }
      let(:charge_params) do
        {
          'type' => 'Charge',
          'amount' => 100,
          'customer_email' => 'qwerty@qwerty.com',
          'customer_phone' => 1_234_567_890,
          'parent_id' => authorize.id
        }
      end
      let(:valid_charge_params) do
        { 'transaction' => charge_params }.to_xml
      end
      let(:invalid_charge_params) do
        { 'transaction' => charge_params.merge('amount' => 0) }.to_xml
      end
      let(:response_body) do
        <<-XML
          <?xml version="1.0" encoding="UTF-8"?>
            <hash>
              <errors>
                <amount type="array">
                  <amount>must be greater than 0</amount>
                </amount>
              </errors>
            </hash>
        XML
      end

      it 'creates charge transaction with valid params in XML format' do
        post :create, body: valid_charge_params, format: :xml

        expect(response.status).to eq(201)
        expect(response.content_type).to eq('application/xml; charset=utf-8')
      end

      it 'does not create charge transaction with invalid params in XML format' do
        post :create, body: invalid_charge_params, format: :xml

        expect(response.status).to eq(422)
        expect(response.content_type).to eq('application/xml; charset=utf-8')
        expect(response.body.squish).to eq(response_body.squish)
      end
    end

    describe 'Create Refund transaction' do
      let(:charge) { create(:charge, user_id: merchant.id) }
      let(:refund_params) do
        {
          'type' => 'Refund',
          'amount' => 100,
          'customer_email' => 'qwerty@qwerty.com',
          'customer_phone' => 1_234_567_890,
          'parent_id' => charge.id
        }
      end
      let(:valid_refund_params) do
        { 'transaction' => refund_params }.to_xml
      end
      let(:invalid_refund_params) do
        { 'transaction' => refund_params.except('customer_email') }.to_xml
      end
      let(:response_body) do
        <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
          <hash>
            <errors>
              <customer-email type="array">
                <customer-email>can't be blank</customer-email>
                <customer-email>Invalid customer email</customer-email>
              </customer-email>
            </errors>
          </hash>
        XML
      end

      it 'creates Refund transaction and refunds Charge transaction in XML format' do
        post :create, body: valid_refund_params, format: :xml

        expect(response.status).to eq(201)
        expect(response.content_type).to eq('application/xml; charset=utf-8')
      end

      it 'does not create Refund transaction and does not refund Charge with invalid params' do
        post :create, body: invalid_refund_params, format: :xml

        expect(response.status).to eq(422)
        expect(response.content_type).to eq('application/xml; charset=utf-8')
        expect(response.body.squish).to eq(response_body.squish)
      end
    end

    describe 'Create Reversal transaction' do
      let(:authorize) { create(:authorize, user_id: merchant.id) }
      let(:reversal_params) do
        {
          'type' => 'Reversal',
          'customer_email' => 'qwerty@qwerty.com',
          'customer_phone' => 1_234_567_890,
          'amount' => 100,
          'parent_id' => authorize.id
        }
      end
      let(:valid_reversal_params) do
        { 'transaction' => reversal_params }.to_xml
      end
      let(:invalid_reversal_params) do
        { 'transaction' => reversal_params.merge('type' => 'invalid type') }.to_xml
      end
      let(:response_body) do
        <<-XML
          <?xml version="1.0" encoding="UTF-8"?>
           <hash>
             <errors>
               <type type="array">
                 <type>Invalid transaction type</type>
               </type>
             </errors>
           </hash>
        XML
      end

      it 'creates Reversal transaction and reverses Authorize transaction in XML format' do
        post :create, body: valid_reversal_params, format: :xml

        expect(response.status).to eq(201)
        expect(response.content_type).to eq('application/xml; charset=utf-8')
      end

      it 'doesnt create Reversal transaction and doesnt reverse Authorize with invalid params' do
        post :create, body: invalid_reversal_params, format: :xml

        expect(response.status).to eq(422)
        expect(response.content_type).to eq('application/xml; charset=utf-8')
        expect(response.body.squish).to eq(response_body.squish)
      end
    end
  end
end
