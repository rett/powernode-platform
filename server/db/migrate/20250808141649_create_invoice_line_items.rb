class CreateInvoiceLineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :invoice_line_items, id: :string do |t|
      t.references :invoice, null: false, foreign_key: true, type: :string
      t.string :description, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.datetime :period_start
      t.datetime :period_end
      t.text :metadata, default: '{}'
      t.string :line_type, default: 'subscription'

      t.timestamps
    end

    add_index :invoice_line_items, :line_type

    add_check_constraint :invoice_line_items, "quantity > 0", name: 'positive_quantity'
    add_check_constraint :invoice_line_items, "unit_price_cents >= 0", name: 'non_negative_unit_price'
    add_check_constraint :invoice_line_items, "total_cents >= 0", name: 'non_negative_total'
    add_check_constraint :invoice_line_items, 
      "line_type IN ('subscription', 'usage', 'discount', 'tax', 'adjustment')", 
      name: 'valid_line_item_type'
  end
end
