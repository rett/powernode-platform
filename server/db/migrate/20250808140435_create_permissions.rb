class CreatePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :permissions, id: :string do |t|
      t.string :name, null: false
      t.string :resource, null: false
      t.string :action, null: false
      t.string :description

      t.timestamps
    end

    add_index :permissions, :name, unique: true
    add_index :permissions, [:resource, :action], unique: true
  end
end
