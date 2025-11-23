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

ActiveRecord::Schema[8.1].define(version: 2025_04_16_180342) do
  create_table "blazer_audits", force: :cascade do |t|
    t.datetime "created_at"
    t.string "data_source"
    t.integer "query_id"
    t.text "statement"
    t.integer "user_id"
    t.index [ "query_id" ], name: "index_blazer_audits_on_query_id"
    t.index [ "user_id" ], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.string "check_type"
    t.datetime "created_at", null: false
    t.integer "creator_id"
    t.text "emails"
    t.datetime "last_run_at"
    t.text "message"
    t.integer "query_id"
    t.string "schedule"
    t.text "slack_channels"
    t.string "state"
    t.datetime "updated_at", null: false
    t.index [ "creator_id" ], name: "index_blazer_checks_on_creator_id"
    t.index [ "query_id" ], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "dashboard_id"
    t.integer "position"
    t.integer "query_id"
    t.datetime "updated_at", null: false
    t.index [ "dashboard_id" ], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index [ "query_id" ], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "creator_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index [ "creator_id" ], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "creator_id"
    t.string "data_source"
    t.text "description"
    t.string "name"
    t.text "statement"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index [ "creator_id" ], name: "index_blazer_queries_on_creator_id"
  end
end
