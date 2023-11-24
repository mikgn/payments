# frozen_string_literal: true

RSpec.describe Admin::MerchantsController, type: :feature do
  let(:username) { 'admin' }
  let(:password) { 'Adminpass' }
  let!(:merchant) { create(:merchant, valid_attributes) }
  let(:valid_attributes) do
    {
      name: 'Test Merchant',
      email: 'test@example.com',
      status: 'active',
      password: 'password',
      password_confirmation: 'password'
    }
  end

  before do
    http_login(username, password)
  end

  describe 'updating a merchant' do
    it 'updates a merchant with valid attributes' do
      visit edit_admin_merchant_path(merchant)

      fill_in 'Name', with: 'Updated Merchant'

      click_button 'Submit'

      expect(page).to have_content('Merchant was successfully updated')
      expect(page).to have_content('Updated Merchant')
    end

    it 'doesnt update a merchant with invalid attributes' do
      visit edit_admin_merchant_path(merchant)

      fill_in 'Name', with: ''

      click_button 'Submit'

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'destroying a merchant' do
    context 'with existing transactions' do
      before do
        create(:authorize, user_id: merchant.id)
      end

      it 'doesnt destroy a merchant' do
        visit edit_admin_merchant_path(merchant)

        click_link 'Delete Merchant'

        expect(page).to have_content('Cannot delete record because dependent transactions exist')
        expect(page).to have_current_path(admin_merchant_path(merchant))
        expect(Merchant.find_by(id: merchant.id)).not_to be_nil
      end
    end

    context 'without existing transactions' do
      it 'destroys a merchant' do
        visit edit_admin_merchant_path(merchant)

        click_link 'Delete Merchant'

        expect(page).to have_content('Merchant was successfully destroyed')
        expect(page).to have_current_path(root_path)
        expect(Merchant.find_by(id: merchant.id)).to be_nil
      end
    end
  end
end
