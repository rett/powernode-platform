class CreatePaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_methods, id: :string do |t|
      t.references :account, null: false, foreign_key: true, type: :string
      t.references :user, null: false, foreign_key: true, type: :string
      t.string :provider, null: false
      t.string :external_id, null: false
      t.string :payment_type, null: false
      t.string :last_four
      t.datetime :expires_at
      t.boolean :is_default, default: false, null: false
      t.text :metadata, default: '{}'

      t.timestamps
    end

    add_index :payment_methods, [:account_id, :is_default]
    add_index :payment_methods, [:provider, :external_id], unique: true
    add_index :payment_methods, :user_id

    add_check_constraint :payment_methods,
      "provider IN ('stripe', 'paypal')",
      name: 'valid_payment_method_provider'
    add_check_constraint :payment_methods,
      "payment_type IN ('card', 'bank', 'paypal', 'apple_pay', 'google_pay')",
      name: 'valid_payment_method_type'
  end
end
