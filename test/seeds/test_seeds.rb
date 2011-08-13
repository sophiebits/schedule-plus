###
# Delete all existing users, scheduled courses, and schedules
###
User.delete_all
ScheduledCourse.delete_all
Schedule.delete_all

###
# Seed with test user/schedule info
###
eric = User.create(:uid => "1326120295", :name => "Eric Wu")
jen = User.create(:uid => "1326120240", :name => "Jen")
vincent = User.create(:uid => "9999", :name => "Vincent Siao")


c15210 = Course.find_by_number("15210")
c15213 = Course.find_by_number("15213")
c15396 = Course.find_by_number("15396")
c21301 = Course.find_by_number("21301")

l15210 = Lecture.find_by_course_id_and_section(c15210.id, '1')
r15210 = Recitation.find_by_lecture_id_and_section(l15210.id, 'D')
sc15210 = ScheduledCourse.create(:course_id => c15210.id, 
                                  :lecture_id => l15210.id, 
                                  :recitation_id => r15210.id)

l15213 = Lecture.find_by_course_id_and_section(c15213.id, '1')
r15213 = Recitation.find_by_lecture_id_and_section(l15213.id, 'F')
sc15213 = ScheduledCourse.create(:course_id => c15213.id, 
                                  :lecture_id => l15213.id, 
                                  :recitation_id => r15213.id)

l15396 = Lecture.find_by_course_id_and_section(c15396.id, 'A')
sc15396 = ScheduledCourse.create(:course_id => c15396.id, 
                                  :lecture_id => l15396.id)

l21301 = Lecture.find_by_course_id_and_section(c21301.id, 'A')
sc21301 = ScheduledCourse.create(:course_id => c21301.id, 
                                  :lecture_id => l21301.id)

Schedule.create(:scheduled_course_id => sc15210.id, :user_id => vincent.id)
Schedule.create(:scheduled_course_id => sc15213.id, :user_id => vincent.id)
Schedule.create(:scheduled_course_id => sc15396.id, :user_id => vincent.id)
Schedule.create(:scheduled_course_id => sc21301.id, :user_id => vincent.id)

Schedule.create(:scheduled_course_id => sc15210.id, :user_id => eric.id)
Schedule.create(:scheduled_course_id => sc15396.id, :user_id => eric.id)

Schedule.create(:scheduled_course_id => sc15396.id, :user_id => jen.id)
Schedule.create(:scheduled_course_id => sc21301.id, :user_id => jen.id)

puts "Completed successfully!"