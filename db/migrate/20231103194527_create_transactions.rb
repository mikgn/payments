class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions, id: :uuid do |t|
      t.string :type, null: false
      t.integer :amount
      t.check_constraint 'amount > 0'
      t.integer :status, null: false
      t.string :customer_email, null: false
      t.string :customer_phone
      t.references :user, null: false, type: :uuid, foreign_key: true
      t.references :parent, type: :uuid, null: true, index: true

      t.timestamps
    end
  end
end
