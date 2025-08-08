class InvoiceLineItem < ApplicationRecord
  # Associations
  belongs_to :invoice

  # Validations
  validates :description, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price_cents, :total_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :line_type, presence: true, inclusion: { in: %w[subscription usage discount tax adjustment] }

  # Serialization
  serialize :metadata, coder: JSON

  # Scopes
  scope :subscription_items, -> { where(line_type: 'subscription') }
  scope :usage_items, -> { where(line_type: 'usage') }
  scope :discounts, -> { where(line_type: 'discount') }
  scope :taxes, -> { where(line_type: 'tax') }
  scope :adjustments, -> { where(line_type: 'adjustment') }

  # Callbacks
  before_save :calculate_total
  after_initialize :set_defaults

  # Money attributes
  monetize :unit_price_cents, :total_cents

  # Instance methods
  def unit_price
    Money.new(unit_price_cents, invoice.currency)
  end

  def total
    Money.new(total_cents, invoice.currency)
  end

  def period_description
    return nil unless period_start && period_end
    "#{period_start.strftime('%b %d')} - #{period_end.strftime('%b %d, %Y')}"
  end

  def proration_factor
    return 1.0 unless period_start && period_end
    
    total_days = (period_end.to_date - period_start.to_date).to_i
    return 1.0 if total_days <= 0
    
    case invoice.subscription.plan.billing_cycle
    when 'monthly'
      total_days / 30.0
    when 'quarterly'
      total_days / 90.0
    when 'yearly'
      total_days / 365.0
    else
      1.0
    end
  end

  def is_prorated?
    proration_factor < 1.0
  end

  private

  def calculate_total
    self.total_cents = quantity * unit_price_cents
  end

  def set_defaults
    self.metadata ||= {}
  end
end
