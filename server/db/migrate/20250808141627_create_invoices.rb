class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices, id: :string do |t|
      t.references :subscription, null: false, foreign_key: true, type: :string
      t.string :invoice_number, null: false
      t.string :status, null: false, default: 'draft'
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :tax_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.string :currency, null: false, default: 'USD'
      t.datetime :due_date
      t.datetime :paid_at
      t.datetime :payment_attempted_at
      t.string :stripe_invoice_id, index: { unique: true, where: "stripe_invoice_id IS NOT NULL" }
      t.string :paypal_invoice_id, index: { unique: true, where: "paypal_invoice_id IS NOT NULL" }
      t.text :metadata, default: '{}'
      t.decimal :tax_rate, precision: 5, scale: 4, default: 0.0
      t.text :billing_address
      t.text :notes

      t.timestamps
    end

    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :status
    add_index :invoices, :due_date
    add_index :invoices, :paid_at
    add_index :invoices, [:subscription_id, :status]

    add_check_constraint :invoices, 
      "status IN ('draft', 'open', 'paid', 'void', 'uncollectible')", 
      name: 'valid_invoice_status'
    add_check_constraint :invoices, "total_cents >= 0", name: 'non_negative_total'
    add_check_constraint :invoices, "subtotal_cents >= 0", name: 'non_negative_subtotal'
    add_check_constraint :invoices, "tax_cents >= 0", name: 'non_negative_tax'
  end
end
