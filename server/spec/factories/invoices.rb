FactoryBot.define do
  factory :invoice do
    subscription { nil }
    invoice_number { "MyString" }
    status { "MyString" }
    subtotal_cents { 1 }
    tax_cents { 1 }
    total_cents { 1 }
    currency { "MyString" }
    due_date { "2025-08-08 06:16:27" }
    paid_at { "2025-08-08 06:16:27" }
    payment_attempted_at { "2025-08-08 06:16:27" }
    stripe_invoice_id { "MyString" }
    paypal_invoice_id { "MyString" }
    metadata { "MyText" }
  end
end
