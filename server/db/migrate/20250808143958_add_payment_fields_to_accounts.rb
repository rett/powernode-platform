class AddPaymentFieldsToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :stripe_customer_id, :string
    add_column :accounts, :paypal_customer_id, :string
    add_column :accounts, :tax_rate, :decimal, precision: 5, scale: 4, default: 0.0
    add_column :accounts, :suspended_at, :datetime
    add_column :accounts, :suspension_reason, :string
    
    add_index :accounts, :stripe_customer_id, unique: true, where: "(stripe_customer_id IS NOT NULL)"
    add_index :accounts, :paypal_customer_id, unique: true, where: "(paypal_customer_id IS NOT NULL)"
    add_index :accounts, :suspended_at
    
    add_check_constraint :accounts, 
      "suspension_reason IN ('non_payment', 'policy_violation', 'manual', 'fraud')", 
      name: 'valid_suspension_reason'
      
    add_check_constraint :accounts, 
      "tax_rate >= 0.0 AND tax_rate <= 1.0", 
      name: 'valid_tax_rate'
  end
end
