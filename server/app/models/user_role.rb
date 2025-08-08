class UserRole < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :role

  # Validations
  validates :user_id, uniqueness: { scope: :role_id }
end
