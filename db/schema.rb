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

ActiveRecord::Schema.define(:version => 20120107143517) do

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  create_table "course_selections", :force => true do |t|
    t.integer  "schedule_id"
    t.integer  "section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", :force => true do |t|
    t.string   "number"
    t.string   "name"
    t.string   "units"
    t.string   "instructor"
    t.text     "description"
    t.string   "prereqs"
    t.string   "coreqs"
    t.integer  "semester_id"
    t.integer  "department_id"
    t.boolean  "offered"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", :force => true do |t|
    t.string   "prefix"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lectures", :force => true do |t|
    t.integer  "course_id"
    t.integer  "number"
    t.string   "instructor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scheduled_times", :force => true do |t|
    t.integer  "schedulable_id"
    t.string   "schedulable_type"
    t.string   "days"
    t.integer  "begin"
    t.integer  "end"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedules", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "semester_id"
    t.boolean  "primary"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", :force => true do |t|
    t.integer  "course_id"
    t.integer  "lecture_id"
    t.string   "letter"
    t.string   "instructor"
    t.boolean  "offered"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "semesters", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.boolean  "current"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "uid"
    t.boolean  "discoverable"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
