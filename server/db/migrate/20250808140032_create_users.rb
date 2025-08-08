class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :string do |t|
      t.references :account, null: false, foreign_key: true, type: :string
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: 'member'
      t.string :status, null: false, default: 'active'
      t.datetime :last_login_at
      t.datetime :email_verified_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, [:account_id, :email], unique: true
    add_index :users, [:account_id, :role]
    add_index :users, :status

    add_check_constraint :users, "role IN ('owner', 'admin', 'member')", name: 'valid_user_role'
    add_check_constraint :users, "status IN ('active', 'inactive', 'suspended')", name: 'valid_user_status'
  end
end
