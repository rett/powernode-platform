class CreateRevenueSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :revenue_snapshots, id: :string do |t|
      t.references :account, null: true, foreign_key: true, type: :string
      t.date :date, null: false
      t.string :period_type, null: false, default: 'daily'
      t.integer :mrr_cents, default: 0, null: false
      t.integer :arr_cents, default: 0, null: false
      t.integer :active_subscriptions_count, default: 0, null: false
      t.integer :new_subscriptions_count, default: 0, null: false
      t.integer :churned_subscriptions_count, default: 0, null: false
      t.integer :total_customers_count, default: 0, null: false
      t.integer :new_customers_count, default: 0, null: false
      t.integer :churned_customers_count, default: 0, null: false
      t.decimal :customer_churn_rate, precision: 5, scale: 4, default: 0.0
      t.decimal :revenue_churn_rate, precision: 5, scale: 4, default: 0.0
      t.decimal :growth_rate, precision: 6, scale: 4, default: 0.0
      t.integer :arpu_cents, default: 0, null: false
      t.integer :ltv_cents, default: 0, null: false
      t.text :metadata, default: '{}'

      t.timestamps
    end
    
    # Indexes for performance
    add_index :revenue_snapshots, [:account_id, :date, :period_type], 
              unique: true, name: 'unique_revenue_snapshot_per_account_date_period'
    add_index :revenue_snapshots, [:date, :period_type], name: 'index_revenue_snapshots_on_date_period'
    add_index :revenue_snapshots, :period_type
    add_index :revenue_snapshots, :date
    add_index :revenue_snapshots, :created_at
    
    # Constraints
    add_check_constraint :revenue_snapshots, 
      "period_type IN ('daily', 'weekly', 'monthly', 'quarterly', 'yearly')", 
      name: 'valid_period_type'
      
    add_check_constraint :revenue_snapshots,
      "mrr_cents >= 0", 
      name: 'non_negative_mrr'
      
    add_check_constraint :revenue_snapshots,
      "arr_cents >= 0", 
      name: 'non_negative_arr'
      
    add_check_constraint :revenue_snapshots,
      "customer_churn_rate >= 0.0 AND customer_churn_rate <= 1.0",
      name: 'valid_customer_churn_rate'
      
    add_check_constraint :revenue_snapshots,
      "revenue_churn_rate >= 0.0 AND revenue_churn_rate <= 1.0",
      name: 'valid_revenue_churn_rate'
  end
end
