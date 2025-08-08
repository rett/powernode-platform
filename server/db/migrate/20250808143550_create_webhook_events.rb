class CreateWebhookEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :webhook_events, id: :string do |t|
      t.string :provider, null: false
      t.string :event_type, null: false
      t.string :provider_event_id, null: false
      t.text :event_data, null: false
      t.string :status, null: false, default: 'pending'
      t.datetime :processed_at
      t.integer :retry_count, default: 0, null: false
      t.text :error_message
      t.text :metadata, default: '{}'
      t.string :account_id

      t.timestamps
    end
    
    add_index :webhook_events, :provider_event_id, unique: true
    add_index :webhook_events, :account_id
    add_index :webhook_events, :status
    add_index :webhook_events, :created_at
    add_index :webhook_events, [:provider, :event_type]
    
    # Add constraints
    add_check_constraint :webhook_events, 
      "provider IN ('stripe', 'paypal')", 
      name: 'valid_webhook_provider'
      
    add_check_constraint :webhook_events, 
      "status IN ('pending', 'processing', 'processed', 'failed', 'skipped')", 
      name: 'valid_webhook_status'
      
    add_check_constraint :webhook_events, 
      "retry_count >= 0 AND retry_count <= 10", 
      name: 'valid_retry_count'
  end
end
