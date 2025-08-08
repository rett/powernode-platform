class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments, id: :string do |t|
      t.references :invoice, null: false, foreign_key: true, type: :string
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: 'USD'
      t.string :status, null: false, default: 'pending'
      t.string :payment_method, null: false
      t.string :stripe_payment_intent_id, index: { unique: true, where: "stripe_payment_intent_id IS NOT NULL" }
      t.string :stripe_charge_id, index: { unique: true, where: "stripe_charge_id IS NOT NULL" }
      t.string :paypal_order_id, index: { unique: true, where: "paypal_order_id IS NOT NULL" }
      t.string :paypal_capture_id, index: { unique: true, where: "paypal_capture_id IS NOT NULL" }
      t.datetime :processed_at
      t.datetime :failed_at
      t.string :failure_reason
      t.text :metadata, default: '{}'
      t.integer :gateway_fee_cents, default: 0
      t.integer :net_amount_cents

      t.timestamps
    end

    add_index :payments, [:invoice_id, :status]
    add_index :payments, :status
    add_index :payments, :payment_method
    add_index :payments, :processed_at

    add_check_constraint :payments, 
      "status IN ('pending', 'processing', 'succeeded', 'failed', 'canceled', 'refunded', 'partially_refunded')", 
      name: 'valid_payment_status'
    add_check_constraint :payments, 
      "payment_method IN ('stripe_card', 'stripe_bank', 'paypal', 'bank_transfer', 'check')", 
      name: 'valid_payment_method'
    add_check_constraint :payments, "amount_cents > 0", name: 'positive_amount'
  end
end
