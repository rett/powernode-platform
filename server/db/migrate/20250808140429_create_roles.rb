class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles, id: :string do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :system_role, default: false, null: false

      t.timestamps
    end

    add_index :roles, :name, unique: true
    add_index :roles, :system_role
  end
end
