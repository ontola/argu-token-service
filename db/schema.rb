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

ActiveRecord::Schema.define(version: 20170801093634) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "tokens", force: :cascade do |t|
    t.string   "secret",                       null: false
    t.integer  "group_id",                     null: false
    t.integer  "usages",       default: 0,     null: false
    t.integer  "max_usages"
    t.datetime "expires_at"
    t.datetime "retracted_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "email"
    t.boolean  "send_mail",    default: false, null: false
    t.datetime "last_used_at"
    t.text     "message"
    t.string   "actor_iri"
    t.string   "invitee"
    t.index ["expires_at", "retracted_at", "group_id"], name: "index_tokens_on_expires_at_and_retracted_at_and_group_id", using: :btree
    t.index ["secret"], name: "index_tokens_on_secret", using: :btree
  end

end
