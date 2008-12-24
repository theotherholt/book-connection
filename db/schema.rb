# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081224182846) do

  create_table "authors", :force => true do |t|
    t.string "name"
  end

  create_table "authors_books", :id => false, :force => true do |t|
    t.integer "author_id"
    t.integer "book_id"
  end

  add_index "authors_books", ["author_id", "book_id"], :name => "author_book_join", :unique => true

  create_table "books", :force => true do |t|
    t.string   "isbn"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "delta"
    t.integer  "posts_count",          :default => 0
    t.integer  "posts_for_sale_count", :default => 0
  end

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "buyer_id"
    t.integer  "book_id"
    t.integer  "edition"
    t.integer  "condition_id"
    t.decimal  "price",                :precision => 5, :scale => 2
    t.datetime "sold_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "posts_for_sale_count",                               :default => 0
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "phone"
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "activation_code"
    t.datetime "activated_at"
    t.datetime "last_login_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "alumni"
    t.string   "alternate_email"
  end

end
