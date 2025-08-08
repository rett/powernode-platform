class AddSecurityFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :failed_login_attempts, :integer, default: 0, null: false
    add_column :users, :locked_until, :datetime
    add_column :users, :password_changed_at, :datetime

    # Add indexes for security queries
    add_index :users, :locked_until
    add_index :users, :password_changed_at
  end
end
