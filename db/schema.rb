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

ActiveRecord::Schema.define(:version => 20120608203724) do

  create_table "certs", :force => true do |t|
    t.string   "fingerprint"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.binary   "cert_data"
    t.integer  "node_id"
    t.boolean  "revoked"
  end

  create_table "node_registrations", :force => true do |t|
    t.integer  "node_id"
    t.integer  "user_id"
    t.string   "standort"
    t.string   "contact_mail"
    t.text     "notice"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "node_name"
    t.string   "operator_name"
  end

  create_table "nodes", :force => true do |t|
    t.integer  "user_id"
    t.text     "position"
    t.text     "bat0_mac"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "wlan_mac"
    t.integer  "status_id"
    t.string   "current_ip"
  end

  create_table "prefix_delegations", :force => true do |t|
    t.integer  "node_id"
    t.string   "v4"
    t.string   "v6"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "subnet_delegations", :force => true do |t|
    t.integer  "node_id"
    t.string   "v4_prefix"
    t.string   "v6_prefix"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tincs", :force => true do |t|
    t.integer  "node_id"
    t.datetime "approved_at"
    t.string   "approved_by"
    t.text     "cert_data"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "rip"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "role_id"
    t.string   "name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
