class PaymentMethod < ApplicationRecord
  belongs_to :account
  belongs_to :user

  validates :provider, presence: true, inclusion: { in: %w[stripe paypal] }
  validates :provider_payment_method_id, presence: true
  validates :payment_method_type, presence: true, inclusion: { 
    in: %w[card bank_account paypal_account] 
  }

  scope :active, -> { where(is_active: true) }
  scope :for_provider, ->(provider) { where(provider: provider) }

  before_create :set_defaults

  def stripe?
    provider == 'stripe'
  end

  def paypal?
    provider == 'paypal'
  end

  def card?
    payment_method_type == 'card'
  end

  def bank_account?
    payment_method_type == 'bank_account'
  end

  def paypal_account?
    payment_method_type == 'paypal_account'
  end

  def display_name
    case payment_method_type
    when 'card'
      "#{card_brand&.capitalize} •••• #{card_last_four}"
    when 'bank_account'
      "Bank Account •••• #{bank_account_last_four}"
    when 'paypal_account'
      "PayPal #{paypal_email}"
    else
      "Payment Method"
    end
  end

  def can_be_used_for_recurring?
    case provider
    when 'stripe'
      %w[card bank_account].include?(payment_method_type)
    when 'paypal'
      paypal_account?
    else
      false
    end
  end

  def deactivate!
    update!(is_active: false, deactivated_at: Time.current)
  end

  private

  def set_defaults
    self.is_active = true if is_active.nil?
    self.created_at = Time.current
  end
end
