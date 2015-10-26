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

ActiveRecord::Schema.define(version: 20151026210659) do

  create_table "summoner_teams", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "summoner_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "summoner_teams", ["summoner_id"], name: "index_summoner_teams_on_summoner_id"
  add_index "summoner_teams", ["team_id"], name: "index_summoner_teams_on_team_id"

  create_table "summoners", force: :cascade do |t|
    t.string   "summonerName"
    t.string   "summoner_ref"
    t.integer  "summonerId"
    t.integer  "summonerLevel"
    t.string   "profileIconId"
    t.integer  "elo"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "teams", force: :cascade do |t|
    t.integer  "tournament_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "summoner_id"
    t.integer  "duo_id"
    t.integer  "tournament_id"
    t.string   "contact_email"
    t.string   "contact_first_name"
    t.string   "contact_last_name"
    t.text     "notification_params"
    t.string   "transaction_id"
    t.string   "status"
    t.datetime "purchased_at"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "tournaments", force: :cascade do |t|
    t.string   "name"
    t.string   "game"
    t.integer  "total_players"
    t.integer  "total_teams"
    t.decimal  "price"
    t.datetime "start_date"
    t.string   "location_name"
    t.string   "location_url"
    t.string   "location_address"
    t.string   "facebook_url"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",             default: false
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

end
