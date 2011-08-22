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

ActiveRecord::Schema.define(:version => 20110814230915) do

  create_table "active_schedules", :force => true do |t|
    t.integer   "user_id"
    t.integer   "schedule_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "course_selections", :force => true do |t|
    t.integer   "schedule_id"
    t.integer   "scheduled_course_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "courses", :force => true do |t|
    t.string    "number"
    t.string    "name"
    t.string    "units"
    t.boolean   "has_recitation"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "lecture_section_times", :force => true do |t|
    t.integer "lecture_id"
    t.string  "day"
    t.integer "begin"
    t.integer "end"
    t.string  "location"
  end

  create_table "lectures", :force => true do |t|
    t.integer "course_id"
    t.string  "section"
    t.string  "instructor"
  end

  create_table "recitation_section_times", :force => true do |t|
    t.integer "recitation_id"
    t.string  "day"
    t.string  "begin"
    t.string  "end"
    t.string  "location"
  end

  create_table "recitations", :force => true do |t|
    t.integer "lecture_id"
    t.string  "section"
    t.string  "instructor"
  end

  create_table "scheduled_courses", :force => true do |t|
    t.integer   "course_id"
    t.integer   "lecture_id"
    t.integer   "recitation_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "schedules", :force => true do |t|
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "students", :force => true do |t|
    t.string    "name"
    t.string    "scheduleman_url"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string    "uid"
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

end
