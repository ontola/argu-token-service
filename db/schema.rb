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

ActiveRecord::Schema[7.0].define(version: 2022_08_15_123313) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "hstore"
  enable_extension "ltree"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "tokens", id: :serial, force: :cascade do |t|
    t.string "secret", null: false
    t.integer "group_id", null: false
    t.integer "usages", default: 0, null: false
    t.integer "max_usages"
    t.datetime "expires_at"
    t.datetime "retracted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.boolean "send_mail", default: false, null: false
    t.datetime "last_used_at"
    t.text "message"
    t.string "actor_iri"
    t.string "invitee"
    t.string "redirect_url"
    t.uuid "root_id", null: false
    t.string "type", null: false
    t.uuid "mail_identifier"
    t.index ["expires_at", "retracted_at", "group_id"], name: "index_tokens_on_expires_at_and_retracted_at_and_group_id"
    t.index ["root_id"], name: "index_tokens_on_root_id"
    t.index ["secret"], name: "index_tokens_on_secret"
  end

end
