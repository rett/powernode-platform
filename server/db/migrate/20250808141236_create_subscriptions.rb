class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions, id: :string do |t|
      t.references :account, null: false, foreign_key: true, type: :string
      t.references :plan, null: false, foreign_key: true, type: :string
      t.string :status, null: false, default: 'trialing'
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :trial_end
      t.datetime :canceled_at
      t.datetime :ended_at
      t.string :stripe_subscription_id, index: { unique: true, where: "stripe_subscription_id IS NOT NULL" }
      t.string :paypal_subscription_id, index: { unique: true, where: "paypal_subscription_id IS NOT NULL" }
      t.text :metadata, default: '{}'
      t.integer :quantity, default: 1, null: false

      t.timestamps
    end

    add_index :subscriptions, [:account_id, :plan_id]
    add_index :subscriptions, :status
    add_index :subscriptions, :current_period_end
    add_index :subscriptions, :trial_end

    add_check_constraint :subscriptions, 
      "status IN ('trialing', 'active', 'past_due', 'canceled', 'unpaid', 'incomplete', 'incomplete_expired', 'paused')", 
      name: 'valid_subscription_status'
    add_check_constraint :subscriptions, "quantity > 0", name: 'positive_quantity'
  end
end
