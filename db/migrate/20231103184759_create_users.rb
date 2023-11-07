class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name
      t.string :role, null: false
      t.string :email, null: false, unique: true
      t.text :description
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
