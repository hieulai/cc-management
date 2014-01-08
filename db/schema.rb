# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140108145546) do

  create_table "accounts", :force => true do |t|
    t.integer  "builder_id"
    t.string   "name"
    t.decimal  "balance",     :precision => 10, :scale => 2
    t.integer  "number"
    t.string   "category"
    t.string   "subcategory"
    t.string   "prefix"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "accounts", ["builder_id"], :name => "index_accounts_on_builder_id"

  create_table "architects", :force => true do |t|
    t.integer  "builder_id"
    t.string   "company"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "primary_phone"
    t.string   "secondary_phone"
    t.string   "website"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.text     "notes"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "primary_phone_tag"
    t.string   "secondary_phone_tag"
  end

  add_index "architects", ["builder_id"], :name => "index_architects_on_builder_id"

  create_table "bids", :force => true do |t|
    t.integer  "project_id"
    t.text     "amount"
    t.text     "notes"
    t.boolean  "chosen"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "vendor_id"
    t.date     "due_date"
    t.integer  "category_id"
  end

  add_index "bids", ["category_id"], :name => "index_bids_on_category_id"
  add_index "bids", ["project_id"], :name => "index_bids_on_project_id"
  add_index "bids", ["vendor_id"], :name => "index_bids_on_vendor_id"

  create_table "bids_items", :force => true do |t|
    t.integer  "bid_id"
    t.integer  "item_id"
    t.decimal  "amount",     :precision => 10, :scale => 2
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "bills", :force => true do |t|
    t.integer  "builder_id"
    t.integer  "project_id"
    t.integer  "vendor_id"
    t.integer  "purchase_order_id"
    t.integer  "categories_template_id"
    t.date     "due_date"
    t.text     "notes"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.decimal  "remaining_amount",       :precision => 10, :scale => 2
  end

  add_index "bills", ["builder_id"], :name => "index_bills_on_builder_id"
  add_index "bills", ["categories_template_id"], :name => "index_bills_on_categories_template_id"
  add_index "bills", ["project_id"], :name => "index_bills_on_project_id"
  add_index "bills", ["purchase_order_id"], :name => "index_bills_on_purchase_order_id"
  add_index "bills", ["vendor_id"], :name => "index_bills_on_vendor_id"

  create_table "bills_items", :force => true do |t|
    t.integer  "bill_id"
    t.integer  "item_id"
    t.string   "description"
    t.decimal  "qty",            :precision => 10, :scale => 2
    t.decimal  "amount",         :precision => 10, :scale => 2
    t.decimal  "estimated_cost", :precision => 10, :scale => 2
    t.decimal  "actual_cost",    :precision => 10, :scale => 2
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  create_table "builders", :force => true do |t|
    t.string   "company_name"
    t.integer  "year_founded"
    t.string   "office_phone"
    t.string   "website"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "tax_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "slogan"
    t.string   "logo"
  end

  create_table "categories", :force => true do |t|
    t.integer  "builder_id"
    t.integer  "template_id"
    t.string   "name"
    t.decimal  "cost_total",       :precision => 10, :scale => 0
    t.decimal  "margin_total",     :precision => 10, :scale => 0
    t.decimal  "price_total",      :precision => 10, :scale => 0
    t.boolean  "default"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "specification_id"
  end

  add_index "categories", ["builder_id"], :name => "index_categories_on_builder_id"
  add_index "categories", ["specification_id"], :name => "index_categories_on_specification_id"
  add_index "categories", ["template_id"], :name => "index_categories_on_template_id"

  create_table "categories_items", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "item_id"
  end

  add_index "categories_items", ["category_id"], :name => "index_categories_items_on_category_id"
  add_index "categories_items", ["item_id"], :name => "index_categories_items_on_item_id"

  create_table "categories_templates", :force => true do |t|
    t.integer "category_id"
    t.integer "template_id"
    t.boolean "purchased"
  end

  add_index "categories_templates", ["category_id"], :name => "index_categories_templates_on_category_id"
  add_index "categories_templates", ["template_id"], :name => "index_categories_templates_on_template_id"

  create_table "categories_templates_items", :id => false, :force => true do |t|
    t.integer "categories_template_id"
    t.integer "item_id"
  end

  add_index "categories_templates_items", ["categories_template_id"], :name => "index_categories_templates_items_on_categories_template_id"
  add_index "categories_templates_items", ["item_id"], :name => "index_categories_templates_items_on_item_id"

  create_table "change_orders", :force => true do |t|
    t.integer  "builder_id"
    t.integer  "project_id"
    t.string   "name"
    t.text     "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "approved"
  end

  add_index "change_orders", ["builder_id"], :name => "index_change_orders_on_builder_id"
  add_index "change_orders", ["project_id"], :name => "index_change_orders_on_project_id"

  create_table "change_orders_categories", :force => true do |t|
    t.integer  "change_order_id"
    t.integer  "category_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "change_orders_categories", ["category_id"], :name => "index_change_orders_categories_on_category_id"
  add_index "change_orders_categories", ["change_order_id"], :name => "index_change_orders_categories_on_change_order_id"

  create_table "clients", :force => true do |t|
    t.integer  "builder_id"
    t.string   "company"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "primary_phone"
    t.string   "secondary_phone"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "lead_source"
    t.date     "last_contacted"
    t.text     "notes"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "status",              :default => "Lead"
    t.string   "primary_phone_tag"
    t.string   "secondary_phone_tag"
  end

  add_index "clients", ["builder_id"], :name => "index_clients_on_builder_id"

  create_table "contacts", :force => true do |t|
    t.integer  "builder_id"
    t.string   "primary_first_name"
    t.string   "primary_last_name"
    t.string   "primary_email"
    t.string   "primary_phone1"
    t.string   "primary_phone2"
    t.string   "primary_phone1_tag"
    t.string   "primary_phone2_tag"
    t.string   "website"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.text     "notes"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "contacts", ["builder_id"], :name => "index_contacts_on_builder_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "deposits", :force => true do |t|
    t.integer  "builder_id"
    t.integer  "account_id"
    t.date     "date"
    t.text     "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "reference"
  end

  create_table "deposits_receipts", :force => true do |t|
    t.integer  "deposit_id"
    t.integer  "receipt_id"
    t.decimal  "amount",     :precision => 10, :scale => 2
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "deposits_receipts", ["deposit_id"], :name => "index_deposits_receipts_on_deposit_id"
  add_index "deposits_receipts", ["receipt_id"], :name => "index_deposits_receipts_on_receipt_id"

  create_table "estimates", :force => true do |t|
    t.integer  "builder_id"
    t.integer  "project_id"
    t.string   "progress"
    t.string   "status",                                    :default => "Current Estimate"
    t.date     "deadline"
    t.decimal  "revenue",    :precision => 10, :scale => 2
    t.decimal  "profit",     :precision => 10, :scale => 2
    t.decimal  "margin",     :precision => 10, :scale => 2
    t.text     "notes"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
    t.string   "kind"
  end

  add_index "estimates", ["builder_id"], :name => "index_estimates_on_builder_id"
  add_index "estimates", ["project_id"], :name => "index_estimates_on_project_id"

  create_table "images", :force => true do |t|
    t.string   "name"
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "invoices", :force => true do |t|
    t.integer  "builder_id"
    t.integer  "estimate_id"
    t.date     "sent_date"
    t.integer  "reference"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.decimal  "remaining_amount", :precision => 10, :scale => 2
    t.date     "invoice_date"
  end

  add_index "invoices", ["builder_id"], :name => "index_invoices_on_builder_id"
  add_index "invoices", ["estimate_id"], :name => "index_invoices_on_estimate_id"

  create_table "invoices_items", :force => true do |t|
    t.integer  "invoice_id"
    t.integer  "item_id"
    t.decimal  "amount",     :precision => 10, :scale => 2
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "items", :force => true do |t|
    t.integer  "builder_id"
    t.integer  "template_id"
    t.integer  "category_id"
    t.string   "name"
    t.string   "description"
    t.decimal  "qty",                       :precision => 10, :scale => 2
    t.string   "unit"
    t.decimal  "estimated_cost",            :precision => 10, :scale => 2
    t.decimal  "markup",                    :precision => 10, :scale => 2
    t.boolean  "default"
    t.text     "notes"
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
    t.string   "file"
    t.decimal  "committed_cost",            :precision => 10, :scale => 2
    t.decimal  "actual_cost",               :precision => 10, :scale => 2
    t.boolean  "change_order",                                             :default => false, :null => false
    t.boolean  "client_billed",                                            :default => false, :null => false
    t.decimal  "uncommitted_cost",          :precision => 10, :scale => 2
    t.decimal  "margin",                    :precision => 10, :scale => 2
    t.integer  "purchase_order_id"
    t.integer  "change_orders_category_id"
    t.integer  "bill_id"
  end

  add_index "items", ["bill_id"], :name => "index_items_on_bill_id"
  add_index "items", ["builder_id"], :name => "index_items_on_builder_id"
  add_index "items", ["category_id"], :name => "index_items_on_category_id"
  add_index "items", ["change_orders_category_id"], :name => "index_items_on_change_orders_category_id"
  add_index "items", ["purchase_order_id"], :name => "index_items_on_purchase_order_id"
  add_index "items", ["template_id"], :name => "index_items_on_template_id"

  create_table "leads", :force => true do |t|
    t.date     "check_back"
    t.date     "last_contacted"
    t.string   "lead_source"
    t.integer  "expected_revenue"
    t.text     "lead_notes"
    t.text     "project_notes"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "measurements", :force => true do |t|
    t.integer  "estimate_id"
    t.string   "name"
    t.string   "unit"
    t.decimal  "amount",      :precision => 10, :scale => 0
    t.integer  "stories"
    t.boolean  "CA"
    t.boolean  "CNC"
    t.boolean  "CR"
    t.boolean  "RA"
    t.boolean  "RNC"
    t.boolean  "RR"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "measurements", ["estimate_id"], :name => "index_measurements_on_estimate_id"

  create_table "payments", :force => true do |t|
    t.integer  "account_id"
    t.date     "date"
    t.string   "memo"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "vendor_id"
    t.string   "method"
    t.integer  "reference"
    t.integer  "builder_id"
  end

  add_index "payments", ["account_id"], :name => "index_payments_on_account_id"
  add_index "payments", ["builder_id"], :name => "index_payments_on_builder_id"
  add_index "payments", ["vendor_id"], :name => "index_payments_on_vendor_id"

  create_table "payments_bills", :force => true do |t|
    t.integer  "payment_id"
    t.integer  "bill_id"
    t.decimal  "amount",     :precision => 10, :scale => 2
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "payments_bills", ["bill_id"], :name => "index_payments_bills_on_bill_id"
  add_index "payments_bills", ["payment_id"], :name => "index_payments_bills_on_payment_id"

  create_table "projects", :force => true do |t|
    t.integer  "client_id"
    t.string   "name"
    t.string   "project_type"
    t.string   "status",                                           :default => "Current Lead"
    t.string   "lead_stage"
    t.decimal  "progress",          :precision => 10, :scale => 0
    t.integer  "revenue"
    t.date     "start_date"
    t.date     "completion_date"
    t.date     "deadline"
    t.integer  "schedule_variance"
    t.string   "next_tasks"
    t.text     "lead_notes"
    t.text     "project_notes"
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
    t.integer  "builder_id"
  end

  add_index "projects", ["builder_id"], :name => "index_projects_on_builder_id"
  add_index "projects", ["client_id"], :name => "index_projects_on_client_id"

  create_table "prospects", :force => true do |t|
    t.integer  "builder_id"
    t.string   "company"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "primary_phone"
    t.string   "primary_phone_tag"
    t.string   "secondary_phone"
    t.string   "secondary_phone_tag"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "lead_source"
    t.date     "last_contacted"
    t.text     "notes"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "prospects", ["builder_id"], :name => "index_prospects_on_builder_id"

  create_table "purchase_orders", :force => true do |t|
    t.integer  "project_id"
    t.integer  "vendor_id"
    t.integer  "categories_template_id"
    t.text     "notes"
    t.boolean  "chosen"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.decimal  "sales_tax_rate",         :precision => 10, :scale => 4
    t.decimal  "shipping",               :precision => 10, :scale => 2
    t.date     "date"
    t.integer  "builder_id"
    t.date     "due_date"
  end

  add_index "purchase_orders", ["builder_id"], :name => "index_purchase_orders_on_builder_id"
  add_index "purchase_orders", ["categories_template_id"], :name => "index_purchase_orders_on_categories_template_id"
  add_index "purchase_orders", ["project_id"], :name => "index_purchase_orders_on_project_id"
  add_index "purchase_orders", ["vendor_id"], :name => "index_purchase_orders_on_vendor_id"

  create_table "purchase_orders_items", :force => true do |t|
    t.integer  "purchase_order_id"
    t.integer  "item_id"
    t.string   "description"
    t.decimal  "qty",               :precision => 10, :scale => 2
    t.decimal  "amount",            :precision => 10, :scale => 2
    t.decimal  "estimated_cost",    :precision => 10, :scale => 2
    t.decimal  "actual_cost",       :precision => 10, :scale => 2
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  create_table "receipts", :force => true do |t|
    t.integer  "builder_id"
    t.integer  "client_id"
    t.string   "method"
    t.date     "received_at"
    t.integer  "reference"
    t.text     "notes"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.decimal  "remaining_amount", :precision => 10, :scale => 2
  end

  create_table "receipts_invoices", :force => true do |t|
    t.integer  "receipt_id"
    t.integer  "invoice_id"
    t.decimal  "amount",     :precision => 10, :scale => 2
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "receipts_invoices", ["invoice_id"], :name => "index_receipts_invoices_on_invoice_id"
  add_index "receipts_invoices", ["receipt_id"], :name => "index_receipts_invoices_on_receipt_id"

  create_table "specifications", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.boolean  "completed"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "description"
  end

  add_index "specifications", ["project_id"], :name => "index_specifications_on_project_id"

  create_table "subcontractors", :force => true do |t|
    t.integer  "builder_id"
    t.string   "company"
    t.string   "trade"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "primary_phone"
    t.string   "secondary_phone"
    t.string   "website"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.text     "notes"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "primary_phone_tag"
    t.string   "secondary_phone_tag"
  end

  add_index "subcontractors", ["builder_id"], :name => "index_subcontractors_on_builder_id"

  create_table "suppliers", :force => true do |t|
    t.integer  "builder_id"
    t.string   "company"
    t.string   "primary_first_name"
    t.string   "primary_last_name"
    t.string   "primary_email"
    t.string   "primary_phone"
    t.string   "secondary_first_name"
    t.string   "secondary_last_name"
    t.string   "secondary_email"
    t.string   "secondary_phone"
    t.string   "website"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.text     "notes"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "primary_phone_tag"
    t.string   "secondary_phone_tag"
  end

  add_index "suppliers", ["builder_id"], :name => "index_suppliers_on_builder_id"

  create_table "tasklists", :force => true do |t|
    t.integer  "builder_id"
    t.integer  "project_id"
    t.string   "name"
    t.integer  "completed"
    t.integer  "total"
    t.boolean  "default"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "tasklists", ["builder_id"], :name => "index_tasklists_on_builder_id"
  add_index "tasklists", ["project_id"], :name => "index_tasklists_on_project_id"

  create_table "tasks", :force => true do |t|
    t.integer  "tasklist_id"
    t.string   "name"
    t.boolean  "completed"
    t.integer  "time_to_complete"
    t.string   "department"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "position",         :default => 0
  end

  add_index "tasks", ["tasklist_id"], :name => "index_tasks_on_tasklist_id"

  create_table "templates", :force => true do |t|
    t.integer  "builder_id"
    t.integer  "estimate_id"
    t.string   "name"
    t.decimal  "cost_total",   :precision => 10, :scale => 0
    t.decimal  "margin_total", :precision => 10, :scale => 0
    t.decimal  "price_total",  :precision => 10, :scale => 0
    t.boolean  "default"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "templates", ["builder_id"], :name => "index_templates_on_builder_id"
  add_index "templates", ["estimate_id"], :name => "index_templates_on_estimate_id"

  create_table "users", :force => true do |t|
    t.integer  "builder_id"
    t.string   "authority"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "primary_phone"
    t.string   "legacy_hashed_password"
    t.string   "legacy_salt"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
  end

  add_index "users", ["builder_id"], :name => "index_users_on_builder_id"

  create_table "vendors", :force => true do |t|
    t.integer  "builder_id"
    t.string   "company"
    t.string   "vendor_type"
    t.string   "trade"
    t.string   "primary_first_name"
    t.string   "primary_last_name"
    t.string   "primary_email"
    t.string   "primary_phone1"
    t.string   "primary_phone2"
    t.string   "primary_phone1_tag"
    t.string   "primary_phone2_tag"
    t.string   "secondary_first_name"
    t.string   "secondary_last_name"
    t.string   "secondary_email"
    t.string   "secondary_phone1"
    t.string   "secondary_phone2"
    t.string   "secondary_phone1_tag"
    t.string   "secondary_phone2_tag"
    t.string   "website"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.text     "notes"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "vendors", ["builder_id"], :name => "index_vendors_on_builder_id"

end
