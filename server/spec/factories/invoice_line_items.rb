FactoryBot.define do
  factory :invoice_line_item do
    invoice { nil }
    description { "MyString" }
    quantity { 1 }
    unit_price_cents { 1 }
    total_cents { 1 }
    period_start { "2025-08-08 06:16:49" }
    period_end { "2025-08-08 06:16:49" }
    metadata { "MyText" }
  end
end
