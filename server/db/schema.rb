# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_08_144824) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.string "subdomain"
    t.string "status", default: "active", null: false
    t.text "settings", default: "{}"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_customer_id"
    t.string "paypal_customer_id"
    t.decimal "tax_rate", precision: 5, scale: 4, default: "0.0"
    t.datetime "suspended_at"
    t.string "suspension_reason"
    t.index ["paypal_customer_id"], name: "index_accounts_on_paypal_customer_id", unique: true, where: "(paypal_customer_id IS NOT NULL)"
    t.index ["status"], name: "index_accounts_on_status"
    t.index ["stripe_customer_id"], name: "index_accounts_on_stripe_customer_id", unique: true, where: "(stripe_customer_id IS NOT NULL)"
    t.index ["subdomain"], name: "index_accounts_on_subdomain", unique: true, where: "(subdomain IS NOT NULL)"
    t.index ["suspended_at"], name: "index_accounts_on_suspended_at"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'suspended'::character varying, 'cancelled'::character varying]::text[])", name: "valid_account_status"
    t.check_constraint "suspension_reason::text = ANY (ARRAY['non_payment'::character varying, 'policy_violation'::character varying, 'manual'::character varying, 'fraud'::character varying]::text[])", name: "valid_suspension_reason"
    t.check_constraint "tax_rate >= 0.0 AND tax_rate <= 1.0", name: "valid_tax_rate"
  end

  create_table "audit_logs", id: :string, force: :cascade do |t|
    t.string "user_id"
    t.string "account_id", null: false
    t.string "action", null: false
    t.string "resource_type", null: false
    t.string "resource_id", null: false
    t.text "old_values"
    t.text "new_values"
    t.text "metadata", default: "{}"
    t.string "ip_address"
    t.string "user_agent"
    t.string "source", default: "web"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_audit_logs_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_audit_logs_on_account_id"
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["resource_type", "resource_id"], name: "index_audit_logs_on_resource_type_and_resource_id"
    t.index ["user_id", "created_at"], name: "index_audit_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
    t.check_constraint "action::text = ANY (ARRAY['create'::character varying, 'update'::character varying, 'delete'::character varying, 'login'::character varying, 'logout'::character varying, 'payment'::character varying, 'subscription_change'::character varying, 'role_change'::character varying]::text[])", name: "valid_audit_action"
    t.check_constraint "source::text = ANY (ARRAY['web'::character varying, 'api'::character varying, 'system'::character varying, 'webhook'::character varying]::text[])", name: "valid_audit_source"
  end

  create_table "invoice_line_items", id: :string, force: :cascade do |t|
    t.string "invoice_id", null: false
    t.string "description", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.datetime "period_start"
    t.datetime "period_end"
    t.text "metadata", default: "{}"
    t.string "line_type", default: "subscription"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_line_items_on_invoice_id"
    t.index ["line_type"], name: "index_invoice_line_items_on_line_type"
    t.check_constraint "line_type::text = ANY (ARRAY['subscription'::character varying, 'usage'::character varying, 'discount'::character varying, 'tax'::character varying, 'adjustment'::character varying]::text[])", name: "valid_line_item_type"
    t.check_constraint "quantity > 0", name: "positive_quantity"
    t.check_constraint "total_cents >= 0", name: "non_negative_total"
    t.check_constraint "unit_price_cents >= 0", name: "non_negative_unit_price"
  end

  create_table "invoices", id: :string, force: :cascade do |t|
    t.string "subscription_id", null: false
    t.string "invoice_number", null: false
    t.string "status", default: "draft", null: false
    t.integer "subtotal_cents", default: 0, null: false
    t.integer "tax_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.string "currency", default: "USD", null: false
    t.datetime "due_date"
    t.datetime "paid_at"
    t.datetime "payment_attempted_at"
    t.string "stripe_invoice_id"
    t.string "paypal_invoice_id"
    t.text "metadata", default: "{}"
    t.decimal "tax_rate", precision: 5, scale: 4, default: "0.0"
    t.text "billing_address"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_date"], name: "index_invoices_on_due_date"
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["paid_at"], name: "index_invoices_on_paid_at"
    t.index ["paypal_invoice_id"], name: "index_invoices_on_paypal_invoice_id", unique: true, where: "(paypal_invoice_id IS NOT NULL)"
    t.index ["status"], name: "index_invoices_on_status"
    t.index ["stripe_invoice_id"], name: "index_invoices_on_stripe_invoice_id", unique: true, where: "(stripe_invoice_id IS NOT NULL)"
    t.index ["subscription_id", "status"], name: "index_invoices_on_subscription_id_and_status"
    t.index ["subscription_id"], name: "index_invoices_on_subscription_id"
    t.check_constraint "status::text = ANY (ARRAY['draft'::character varying, 'open'::character varying, 'paid'::character varying, 'void'::character varying, 'uncollectible'::character varying]::text[])", name: "valid_invoice_status"
    t.check_constraint "subtotal_cents >= 0", name: "non_negative_subtotal"
    t.check_constraint "tax_cents >= 0", name: "non_negative_tax"
    t.check_constraint "total_cents >= 0", name: "non_negative_total"
  end

  create_table "payment_methods", id: :string, force: :cascade do |t|
    t.string "account_id", null: false
    t.string "user_id", null: false
    t.string "provider", null: false
    t.string "external_id", null: false
    t.string "payment_type", null: false
    t.string "last_four"
    t.datetime "expires_at"
    t.boolean "is_default", default: false, null: false
    t.text "metadata", default: "{}"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "is_default"], name: "index_payment_methods_on_account_id_and_is_default"
    t.index ["account_id"], name: "index_payment_methods_on_account_id"
    t.index ["provider", "external_id"], name: "index_payment_methods_on_provider_and_external_id", unique: true
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
    t.check_constraint "payment_type::text = ANY (ARRAY['card'::character varying, 'bank'::character varying, 'paypal'::character varying, 'apple_pay'::character varying, 'google_pay'::character varying]::text[])", name: "valid_payment_method_type"
    t.check_constraint "provider::text = ANY (ARRAY['stripe'::character varying, 'paypal'::character varying]::text[])", name: "valid_payment_method_provider"
  end

  create_table "payments", id: :string, force: :cascade do |t|
    t.string "invoice_id", null: false
    t.integer "amount_cents", null: false
    t.string "currency", default: "USD", null: false
    t.string "status", default: "pending", null: false
    t.string "payment_method", null: false
    t.string "stripe_payment_intent_id"
    t.string "stripe_charge_id"
    t.string "paypal_order_id"
    t.string "paypal_capture_id"
    t.datetime "processed_at"
    t.datetime "failed_at"
    t.string "failure_reason"
    t.text "metadata", default: "{}"
    t.integer "gateway_fee_cents", default: 0
    t.integer "net_amount_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id", "status"], name: "index_payments_on_invoice_id_and_status"
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
    t.index ["payment_method"], name: "index_payments_on_payment_method"
    t.index ["paypal_capture_id"], name: "index_payments_on_paypal_capture_id", unique: true, where: "(paypal_capture_id IS NOT NULL)"
    t.index ["paypal_order_id"], name: "index_payments_on_paypal_order_id", unique: true, where: "(paypal_order_id IS NOT NULL)"
    t.index ["processed_at"], name: "index_payments_on_processed_at"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["stripe_charge_id"], name: "index_payments_on_stripe_charge_id", unique: true, where: "(stripe_charge_id IS NOT NULL)"
    t.index ["stripe_payment_intent_id"], name: "index_payments_on_stripe_payment_intent_id", unique: true, where: "(stripe_payment_intent_id IS NOT NULL)"
    t.check_constraint "amount_cents > 0", name: "positive_amount"
    t.check_constraint "payment_method::text = ANY (ARRAY['stripe_card'::character varying, 'stripe_bank'::character varying, 'paypal'::character varying, 'bank_transfer'::character varying, 'check'::character varying]::text[])", name: "valid_payment_method"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'processing'::character varying, 'succeeded'::character varying, 'failed'::character varying, 'canceled'::character varying, 'refunded'::character varying, 'partially_refunded'::character varying]::text[])", name: "valid_payment_status"
  end

  create_table "permissions", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.string "resource", null: false
    t.string "action", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_permissions_on_name", unique: true
    t.index ["resource", "action"], name: "index_permissions_on_resource_and_action", unique: true
  end

  create_table "plans", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "price_cents", default: 0, null: false
    t.string "currency", default: "USD", null: false
    t.string "billing_cycle", default: "monthly", null: false
    t.text "features", default: "{}"
    t.text "limits", default: "{}"
    t.string "status", default: "active", null: false
    t.text "default_roles", default: "[]"
    t.integer "trial_days", default: 0
    t.boolean "public", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["billing_cycle"], name: "index_plans_on_billing_cycle"
    t.index ["name"], name: "index_plans_on_name", unique: true
    t.index ["public"], name: "index_plans_on_public"
    t.index ["status"], name: "index_plans_on_status"
    t.check_constraint "billing_cycle::text = ANY (ARRAY['monthly'::character varying, 'yearly'::character varying, 'quarterly'::character varying]::text[])", name: "valid_billing_cycle"
    t.check_constraint "currency::text = ANY (ARRAY['USD'::character varying, 'EUR'::character varying, 'GBP'::character varying]::text[])", name: "valid_currency"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying, 'archived'::character varying]::text[])", name: "valid_plan_status"
  end

  create_table "revenue_snapshots", id: :string, force: :cascade do |t|
    t.string "account_id"
    t.date "date", null: false
    t.string "period_type", default: "daily", null: false
    t.integer "mrr_cents", default: 0, null: false
    t.integer "arr_cents", default: 0, null: false
    t.integer "active_subscriptions_count", default: 0, null: false
    t.integer "new_subscriptions_count", default: 0, null: false
    t.integer "churned_subscriptions_count", default: 0, null: false
    t.integer "total_customers_count", default: 0, null: false
    t.integer "new_customers_count", default: 0, null: false
    t.integer "churned_customers_count", default: 0, null: false
    t.decimal "customer_churn_rate", precision: 5, scale: 4, default: "0.0"
    t.decimal "revenue_churn_rate", precision: 5, scale: 4, default: "0.0"
    t.decimal "growth_rate", precision: 6, scale: 4, default: "0.0"
    t.integer "arpu_cents", default: 0, null: false
    t.integer "ltv_cents", default: 0, null: false
    t.text "metadata", default: "{}"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "date", "period_type"], name: "unique_revenue_snapshot_per_account_date_period", unique: true
    t.index ["account_id"], name: "index_revenue_snapshots_on_account_id"
    t.index ["created_at"], name: "index_revenue_snapshots_on_created_at"
    t.index ["date", "period_type"], name: "index_revenue_snapshots_on_date_period"
    t.index ["date"], name: "index_revenue_snapshots_on_date"
    t.index ["period_type"], name: "index_revenue_snapshots_on_period_type"
    t.check_constraint "arr_cents >= 0", name: "non_negative_arr"
    t.check_constraint "customer_churn_rate >= 0.0 AND customer_churn_rate <= 1.0", name: "valid_customer_churn_rate"
    t.check_constraint "mrr_cents >= 0", name: "non_negative_mrr"
    t.check_constraint "period_type::text = ANY (ARRAY['daily'::character varying, 'weekly'::character varying, 'monthly'::character varying, 'quarterly'::character varying, 'yearly'::character varying]::text[])", name: "valid_period_type"
    t.check_constraint "revenue_churn_rate >= 0.0 AND revenue_churn_rate <= 1.0", name: "valid_revenue_churn_rate"
  end

  create_table "role_permissions", id: :string, force: :cascade do |t|
    t.string "role_id", null: false
    t.string "permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.boolean "system_role", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
    t.index ["system_role"], name: "index_roles_on_system_role"
  end

  create_table "subscriptions", id: :string, force: :cascade do |t|
    t.string "account_id", null: false
    t.string "plan_id", null: false
    t.string "status", default: "trialing", null: false
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.datetime "trial_end"
    t.datetime "canceled_at"
    t.datetime "ended_at"
    t.string "stripe_subscription_id"
    t.string "paypal_subscription_id"
    t.text "metadata", default: "{}"
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "plan_id"], name: "index_subscriptions_on_account_id_and_plan_id"
    t.index ["account_id"], name: "index_subscriptions_on_account_id"
    t.index ["current_period_end"], name: "index_subscriptions_on_current_period_end"
    t.index ["paypal_subscription_id"], name: "index_subscriptions_on_paypal_subscription_id", unique: true, where: "(paypal_subscription_id IS NOT NULL)"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true, where: "(stripe_subscription_id IS NOT NULL)"
    t.index ["trial_end"], name: "index_subscriptions_on_trial_end"
    t.check_constraint "quantity > 0", name: "positive_quantity"
    t.check_constraint "status::text = ANY (ARRAY['trialing'::character varying, 'active'::character varying, 'past_due'::character varying, 'canceled'::character varying, 'unpaid'::character varying, 'incomplete'::character varying, 'incomplete_expired'::character varying, 'paused'::character varying]::text[])", name: "valid_subscription_status"
  end

  create_table "user_roles", id: :string, force: :cascade do |t|
    t.string "user_id", null: false
    t.string "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.string "account_id", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "member", null: false
    t.string "status", default: "active", null: false
    t.datetime "last_login_at"
    t.datetime "email_verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "email"], name: "index_users_on_account_id_and_email", unique: true
    t.index ["account_id", "role"], name: "index_users_on_account_id_and_role"
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["status"], name: "index_users_on_status"
    t.check_constraint "role::text = ANY (ARRAY['owner'::character varying, 'admin'::character varying, 'member'::character varying]::text[])", name: "valid_user_role"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying, 'suspended'::character varying]::text[])", name: "valid_user_status"
  end

  create_table "webhook_events", id: :string, force: :cascade do |t|
    t.string "provider", null: false
    t.string "event_type", null: false
    t.string "provider_event_id", null: false
    t.text "event_data", null: false
    t.string "status", default: "pending", null: false
    t.datetime "processed_at"
    t.integer "retry_count", default: 0, null: false
    t.text "error_message"
    t.text "metadata", default: "{}"
    t.string "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_webhook_events_on_account_id"
    t.index ["created_at"], name: "index_webhook_events_on_created_at"
    t.index ["provider", "event_type"], name: "index_webhook_events_on_provider_and_event_type"
    t.index ["provider_event_id"], name: "index_webhook_events_on_provider_event_id", unique: true
    t.index ["status"], name: "index_webhook_events_on_status"
    t.check_constraint "provider::text = ANY (ARRAY['stripe'::character varying, 'paypal'::character varying]::text[])", name: "valid_webhook_provider"
    t.check_constraint "retry_count >= 0 AND retry_count <= 10", name: "valid_retry_count"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'processing'::character varying, 'processed'::character varying, 'failed'::character varying, 'skipped'::character varying]::text[])", name: "valid_webhook_status"
  end

  add_foreign_key "audit_logs", "accounts"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "invoice_line_items", "invoices"
  add_foreign_key "invoices", "subscriptions"
  add_foreign_key "payment_methods", "accounts"
  add_foreign_key "payment_methods", "users"
  add_foreign_key "payments", "invoices"
  add_foreign_key "revenue_snapshots", "accounts"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "subscriptions", "accounts"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "accounts"
end
