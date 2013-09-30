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

ActiveRecord::Schema.define(version: 20130930121735) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "blocks", force: true do |t|
    t.integer  "website_id"
    t.integer  "parent"
    t.string   "genre"
    t.hstore   "details"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordinal",    default: 1000
  end

  add_index "blocks", ["details"], name: "index_blocks_on_details", using: :gist
  add_index "blocks", ["parent"], name: "index_blocks_on_parent", using: :btree
  add_index "blocks", ["website_id"], name: "index_blocks_on_website_id", using: :btree

  create_table "documents", force: true do |t|
    t.integer  "theme_id"
    t.string   "name"
    t.string   "extension"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "documents", ["theme_id"], name: "index_documents_on_theme_id", using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "website_id"
    t.string   "security"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree
  add_index "memberships", ["website_id"], name: "index_memberships_on_website_id", using: :btree

  create_table "pages", force: true do |t|
    t.string   "title"
    t.string   "permalink"
    t.text     "description"
    t.boolean  "visible"
    t.integer  "ordinal"
    t.integer  "document_id"
    t.integer  "parent_id"
    t.integer  "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["document_id"], name: "index_pages_on_document_id", using: :btree
  add_index "pages", ["parent_id"], name: "index_pages_on_parent_id", using: :btree
  add_index "pages", ["permalink"], name: "index_pages_on_permalink", using: :btree
  add_index "pages", ["website_id"], name: "index_pages_on_website_id", using: :btree

  create_table "themes", force: true do |t|
    t.string   "name"
    t.integer  "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pristine",   default: false
  end

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

  create_table "websites", force: true do |t|
    t.string   "title"
    t.string   "permalink"
    t.integer  "theme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "home_id"
  end

  add_index "websites", ["home_id"], name: "index_websites_on_home_id", using: :btree
  add_index "websites", ["theme_id"], name: "index_websites_on_theme_id", using: :btree

  create_table "widgets", force: true do |t|
    t.integer  "website_id"
    t.integer  "parent"
    t.string   "genre"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "widgets", ["parent"], name: "index_widgets_on_parent", using: :btree
  add_index "widgets", ["website_id"], name: "index_widgets_on_website_id", using: :btree

end
