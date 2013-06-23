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

ActiveRecord::Schema.define(:version => 20130620092124) do

  create_table "architects", :force => true do |t|
    t.string   "company"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "primary_phone"
    t.integer  "secondary_phone"
    t.string   "website"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.integer  "zipcode"
    t.text     "notes"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "builders", :force => true do |t|
    t.string   "company_name"
    t.integer  "year_founded"
    t.string   "office_phone"
    t.string   "website"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.integer  "zipcode"
    t.integer  "tax_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "categories", :force => true do |t|
    t.integer  "builder_id"
    t.integer  "template_id"
    t.string   "name"
    t.decimal  "cost_total",   :precision => 10, :scale => 0
    t.decimal  "margin_total", :precision => 10, :scale => 0
    t.decimal  "price_total",  :precision => 10, :scale => 0
    t.boolean  "default"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "categories", ["builder_id"], :name => "index_categories_on_builder_id"
  add_index "categories", ["template_id"], :name => "index_categories_on_template_id"

  create_table "categories_items", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "item_id"
  end

  add_index "categories_items", ["category_id"], :name => "index_categories_items_on_category_id"
  add_index "categories_items", ["item_id"], :name => "index_categories_items_on_item_id"

  create_table "categories_templates", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "template_id"
  end

  add_index "categories_templates", ["category_id"], :name => "index_categories_templates_on_category_id"
  add_index "categories_templates", ["template_id"], :name => "index_categories_templates_on_template_id"

  create_table "clients", :force => true do |t|
    t.string   "company"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "primary_phone"
    t.integer  "secondary_phone"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.integer  "zipcode"
    t.string   "lead_source"
    t.date     "last_contacted"
    t.text     "notes"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "estimates", :force => true do |t|
    t.integer  "project_id"
    t.string   "template"
    t.string   "progress"
    t.string   "status",     :default => "Current Estimate"
    t.date     "deadline"
    t.integer  "revenue"
    t.integer  "profit"
    t.integer  "margin"
    t.text     "notes"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "estimates", ["project_id"], :name => "index_estimates_on_project_id"

  create_table "items", :force => true do |t|
    t.integer  "builder_id"
    t.integer  "template_id"
    t.integer  "category_id"
    t.string   "name"
    t.string   "description"
    t.decimal  "qty",         :precision => 10, :scale => 2
    t.string   "unit"
    t.decimal  "cost",        :precision => 10, :scale => 2
    t.decimal  "margin",      :precision => 10, :scale => 2
    t.boolean  "default"
    t.text     "notes"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "items", ["builder_id"], :name => "index_items_on_builder_id"
  add_index "items", ["category_id"], :name => "index_items_on_category_id"
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
  end

  add_index "projects", ["client_id"], :name => "index_projects_on_client_id"

  create_table "subcontractors", :force => true do |t|
    t.string   "company"
    t.string   "trade"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "primary_phone"
    t.integer  "secondary_phone"
    t.string   "website"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.integer  "zipcode"
    t.text     "notes"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "suppliers", :force => true do |t|
    t.string   "company"
    t.string   "primary_first_name"
    t.string   "primary_last_name"
    t.string   "primary_email"
    t.integer  "primary_phone"
    t.string   "secondary_first_name"
    t.string   "secondary_last_name"
    t.string   "secondary_email"
    t.integer  "secondary_phone"
    t.string   "website"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.integer  "zipcode"
    t.text     "notes"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "tasklists", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tasks", :force => true do |t|
    t.integer  "name"
    t.boolean  "completed"
    t.integer  "time_to_complete"
    t.string   "department"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

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
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "primary_phone"
    t.string   "password"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
