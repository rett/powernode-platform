class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs, id: :string do |t|
      t.references :user, null: true, foreign_key: true, type: :string
      t.references :account, null: false, foreign_key: true, type: :string
      t.string :action, null: false
      t.string :resource_type, null: false
      t.string :resource_id, null: false
      t.text :old_values
      t.text :new_values
      t.text :metadata, default: '{}'
      t.string :ip_address
      t.string :user_agent
      t.string :source, default: 'web'

      t.timestamps
    end

    add_index :audit_logs, [:account_id, :created_at]
    add_index :audit_logs, [:user_id, :created_at]
    add_index :audit_logs, [:resource_type, :resource_id]
    add_index :audit_logs, :action
    add_index :audit_logs, :created_at

    add_check_constraint :audit_logs, 
      "action IN ('create', 'update', 'delete', 'login', 'logout', 'payment', 'subscription_change', 'role_change')", 
      name: 'valid_audit_action'
    add_check_constraint :audit_logs, 
      "source IN ('web', 'api', 'system', 'webhook')", 
      name: 'valid_audit_source'
  end
end
