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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131104135356) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "addons", force: true do |t|
    t.string   "name"
    t.string   "permalink"
    t.integer  "price"
    t.boolean  "quantifiable"
    t.boolean  "available"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addonships", force: true do |t|
    t.integer  "website_id"
    t.integer  "addon_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity",   default: 0
  end

  add_index "addonships", ["addon_id"], name: "index_addonships_on_addon_id", using: :btree
  add_index "addonships", ["website_id"], name: "index_addonships_on_website_id", using: :btree

  create_table "blocks", force: true do |t|
    t.integer  "website_id"
    t.integer  "wrapper_id"
    t.string   "genre"
    t.hstore   "details"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordinal",    default: 1000
    t.boolean  "columnizes", default: false
    t.integer  "parent_id"
    t.float    "width"
  end

  add_index "blocks", ["details"], name: "index_blocks_on_details", using: :gist
  add_index "blocks", ["parent_id"], name: "index_blocks_on_parent_id", using: :btree
  add_index "blocks", ["website_id"], name: "index_blocks_on_website_id", using: :btree
  add_index "blocks", ["wrapper_id"], name: "index_blocks_on_wrapper_id", using: :btree

  create_table "documents", force: true do |t|
    t.integer  "theme_id"
    t.string   "name"
    t.string   "extension"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "documents", ["theme_id"], name: "index_documents_on_theme_id", using: :btree

  create_table "email_addresses", force: true do |t|
    t.integer  "website_id"
    t.string   "user"
    t.string   "domain"
    t.string   "encrypted_password"
    t.string   "forward_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_addresses", ["website_id"], name: "index_email_addresses_on_website_id", using: :btree

  create_table "invoices", force: true do |t|
    t.integer  "website_id"
    t.datetime "date"
    t.string   "stripe_id"
    t.datetime "period_start"
    t.datetime "period_end"
    t.text     "lines"
    t.integer  "subtotal"
    t.integer  "total"
    t.boolean  "paid"
    t.integer  "attemp_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attempt_count"
    t.string   "visible_id"
    t.integer  "membership_id"
    t.string   "customer_token"
    t.integer  "netbuild_website_id"
    t.float    "tax_rate"
    t.boolean  "public_access",       default: false
  end

  add_index "invoices", ["customer_token"], name: "index_invoices_on_customer_token", using: :btree
  add_index "invoices", ["membership_id"], name: "index_invoices_on_membership_id", using: :btree
  add_index "invoices", ["netbuild_website_id"], name: "index_invoices_on_netbuild_website_id", using: :btree
  add_index "invoices", ["visible_id"], name: "index_invoices_on_visible_id", using: :btree
  add_index "invoices", ["website_id"], name: "index_invoices_on_website_id", using: :btree

  create_table "media", force: true do |t|
    t.integer  "website_id"
    t.string   "path"
    t.string   "name"
    t.string   "description"
    t.integer  "width"
    t.integer  "height"
    t.integer  "size"
    t.integer  "user_id"
    t.string   "extension"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "media", ["user_id"], name: "index_media_on_user_id", using: :btree
  add_index "media", ["website_id"], name: "index_media_on_website_id", using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "website_id"
    t.string   "security"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.boolean  "has_email_account"
    t.string   "forward_to"
    t.string   "encrpyted_password"
    t.string   "encrypted_password"
    t.string   "customer_token"
    t.string   "card_token"
    t.integer  "last_4"
  end

  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree
  add_index "memberships", ["website_id"], name: "index_memberships_on_website_id", using: :btree

  create_table "pages", force: true do |t|
    t.string   "title"
    t.string   "permalink"
    t.text     "description"
    t.boolean  "visible",     default: true
    t.integer  "ordinal"
    t.integer  "document_id"
    t.integer  "parent_id"
    t.integer  "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleteable",  default: false
    t.string   "redirect"
    t.string   "redirect_to"
  end

  add_index "pages", ["document_id"], name: "index_pages_on_document_id", using: :btree
  add_index "pages", ["parent_id"], name: "index_pages_on_parent_id", using: :btree
  add_index "pages", ["website_id"], name: "index_pages_on_website_id", using: :btree

  create_table "themes", force: true do |t|
    t.string   "name"
    t.integer  "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pristine",            default: false
    t.integer  "default_document_id"
  end

  add_index "themes", ["default_document_id"], name: "index_themes_on_default_document_id", using: :btree
  add_index "themes", ["website_id"], name: "index_themes_on_website_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "websites", force: true do |t|
    t.string   "title"
    t.string   "permalink"
    t.integer  "theme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "home_id"
    t.string   "domain"
    t.string   "primary_colour"
    t.string   "secondary_colour"
    t.string   "stripe_token"
    t.string   "customer_token"
    t.integer  "bill_day_of_month",     default: 1
    t.integer  "last_4"
    t.hstore   "addons"
    t.integer  "free_email_addresses",  default: 2
    t.integer  "email_addresses_count", default: 0
    t.text     "header"
    t.string   "stripe_access_token"
    t.string   "stripe_user_id"
    t.text     "address"
    t.text     "invoice_blurb"
  end

  add_index "websites", ["domain"], name: "index_websites_on_domain", using: :btree
  add_index "websites", ["home_id"], name: "index_websites_on_home_id", using: :btree
  add_index "websites", ["theme_id"], name: "index_websites_on_theme_id", using: :btree

  create_table "wrappers", force: true do |t|
    t.string   "identifier"
    t.integer  "page_id"
    t.integer  "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "columnizes", default: false
    t.integer  "block_id"
    t.float    "width"
  end

  add_index "wrappers", ["block_id"], name: "index_wrappers_on_block_id", using: :btree
  add_index "wrappers", ["page_id"], name: "index_wrappers_on_page_id", using: :btree
  add_index "wrappers", ["website_id"], name: "index_wrappers_on_website_id", using: :btree

end
