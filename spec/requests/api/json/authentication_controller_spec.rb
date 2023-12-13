# frozen_string_literal: true

RSpec.describe Api::AuthenticationController, type: :controller do
  let!(:merchant) { create(:merchant) }
  let(:key) { Rails.application.secrets.secret_key_base.to_s }
  let(:auth_params) do
    {
      merchant: {
        email: merchant.email,
        password: merchant.password
      }
    }
  end

  describe 'POST /auth/login' do
    context 'with valid params' do
      it 'responds with a valid JWT' do
        post :login, params: auth_params

        token = JSON.parse(response.body)['token']

        expect(response.status).to eq(200)
        expect(JWT.decode(token, key).first['user_id']).to eq(merchant.id)
      end
    end

    context 'with invalid params' do
      it 'authentication fails' do
        post :login, params: auth_params.merge({ merchant: { password: 'invalid' } })

        expect(response.status).to eq(401)
        expect(response.body).to eq({ error: 'unauthorized' }.to_json)
      end
    end
  end
end
