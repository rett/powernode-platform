class CreatePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :plans, id: :string do |t|
      t.string :name, null: false
      t.text :description
      t.integer :price_cents, null: false, default: 0
      t.string :currency, null: false, default: 'USD'
      t.string :billing_cycle, null: false, default: 'monthly'
      t.text :features, default: '{}'
      t.text :limits, default: '{}'
      t.string :status, null: false, default: 'active'
      t.text :default_roles, default: '[]'
      t.integer :trial_days, default: 0
      t.boolean :public, default: true, null: false

      t.timestamps
    end

    add_index :plans, :name, unique: true
    add_index :plans, :status
    add_index :plans, :billing_cycle
    add_index :plans, :public

    add_check_constraint :plans, "status IN ('active', 'inactive', 'archived')", name: 'valid_plan_status'
    add_check_constraint :plans, "billing_cycle IN ('monthly', 'yearly', 'quarterly')", name: 'valid_billing_cycle'
    add_check_constraint :plans, "currency IN ('USD', 'EUR', 'GBP')", name: 'valid_currency'
  end
end
