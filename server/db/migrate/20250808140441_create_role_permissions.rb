class CreateRolePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :role_permissions, id: :string do |t|
      t.references :role, null: false, foreign_key: true, type: :string
      t.references :permission, null: false, foreign_key: true, type: :string

      t.timestamps
    end

    add_index :role_permissions, [:role_id, :permission_id], unique: true
  end
end
