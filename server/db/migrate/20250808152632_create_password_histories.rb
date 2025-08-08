class CreatePasswordHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :password_histories, id: :string do |t|
      t.references :user, null: false, foreign_key: true, type: :string
      t.string :password_digest, null: false
      t.datetime :created_at, null: false

      # Add index for efficient lookups
      t.index [:user_id, :created_at], name: 'index_password_histories_on_user_and_created_at'
    end
  end
end
