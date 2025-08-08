class User < ApplicationRecord
  # Authentication
  has_secure_password

  # Associations
  belongs_to :account
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :audit_logs, dependent: :nullify

  # Validations
  validates :email, presence: true, 
                   format: { with: URI::MailTo::EMAIL_REGEXP },
                   uniqueness: { case_sensitive: false }
  validates :first_name, presence: true, length: { minimum: 1, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 1, maximum: 50 }
  validates :role, presence: true, inclusion: { in: %w[owner admin member] }
  validates :status, presence: true, inclusion: { in: %w[active inactive suspended] }

  # Callbacks
  before_validation :normalize_email
  before_create :set_owner_if_first_user

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :owners, -> { where(role: 'owner') }
  scope :admins, -> { where(role: 'admin') }
  scope :members, -> { where(role: 'member') }
  scope :verified, -> { where.not(email_verified_at: nil) }
  scope :unverified, -> { where(email_verified_at: nil) }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def initials
    "#{first_name[0]}#{last_name[0]}".upcase
  end

  def active?
    status == 'active'
  end

  def owner?
    role == 'owner'
  end

  def admin?
    role == 'admin'
  end

  def member?
    role == 'member'
  end

  def email_verified?
    email_verified_at.present?
  end

  def verify_email!
    update!(email_verified_at: Time.current)
  end

  def record_login!
    update!(last_login_at: Time.current)
  end

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def has_permission?(permission_name)
    roles.joins(:permissions).exists(permissions: { name: permission_name })
  end

  def assign_role(role)
    roles << role unless has_role?(role.name)
  end

  def remove_role(role)
    roles.delete(role)
  end

  def all_permissions
    Permission.joins(:roles).where(roles: { id: role_ids })
  end

  # Analytics permission helper methods
  def can?(permission_action)
    case permission_action.to_s
    when 'view_analytics'
      has_permission?('analytics_read') || owner? || admin?
    when 'export_analytics'
      has_permission?('analytics_export') || owner? || admin?
    when 'view_global_analytics'
      has_permission?('analytics_global') || owner?
    else
      false
    end
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end

  def set_owner_if_first_user
    if account&.users&.count&.zero?
      self.role = 'owner'
    end
  end
end
