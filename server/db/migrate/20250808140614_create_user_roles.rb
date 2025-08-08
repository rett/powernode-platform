class CreateUserRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_roles, id: :string do |t|
      t.references :user, null: false, foreign_key: true, type: :string
      t.references :role, null: false, foreign_key: true, type: :string

      t.timestamps
    end

    add_index :user_roles, [:user_id, :role_id], unique: true
  end
end
