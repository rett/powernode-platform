class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts, id: :string do |t|
      t.string :name, null: false
      t.string :subdomain, null: true, index: { unique: true, where: "subdomain IS NOT NULL" }
      t.string :status, null: false, default: 'active'
      t.text :settings, default: '{}'

      t.timestamps
    end

    add_index :accounts, :status
    add_check_constraint :accounts, "status IN ('active', 'suspended', 'cancelled')", name: 'valid_account_status'
  end
end
