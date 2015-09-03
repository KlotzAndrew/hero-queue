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

ActiveRecord::Schema.define(version: 20150903035940) do

  create_table "summoners", force: :cascade do |t|
    t.string   "summonerName"
    t.string   "summoner_ref"
    t.integer  "summonerId"
    t.integer  "summonerLevel"
    t.string   "profileIconId"
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
    t.datetime "purchased_at"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "tournaments", force: :cascade do |t|
    t.string   "name"
    t.string   "game"
    t.integer  "total_players"
    t.integer  "total_teams"
    t.string   "start_date"
    t.string   "location"
    t.string   "facebook_url"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
