###
# Delete all existing users, scheduled courses, and schedules
###
User.delete_all
ScheduledCourse.delete_all
Schedule.delete_all
ActiveSchedule.delete_all
CourseSelection.delete_all

###
# Seed with test user/schedule info
###
temp = User.create(:uid    => "-1", :name => "Temp User")
eric = User.create(:uid    => "1326120295", :name => "Eric Wu")
jen = User.create(:uid     => "1326120240", :name => "Jen Solyanik")
vincent = User.create(:uid => "1638210122", :name => "Vincent Siao")
jason = User.create(:uid   => "1232652999", :name => "Jason MacDonald")

c15210 = Course.find_by_number("15-210")
c15213 = Course.find_by_number("15-213")
c15396 = Course.find_by_number("15-396")
c21301 = Course.find_by_number("21-301")

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

vs = Schedule.create(:user_id => vincent.id)
es = Schedule.create(:user_id => eric.id)
js = Schedule.create(:user_id => jen.id)
jmacs = Schedule.create(:user_id => jason.id)

ActiveSchedule.create([{:user_id => vincent.id, :schedule_id => vs.id},
                       {:user_id => eric.id, :schedule_id => es.id},
                       {:user_id => jen.id, :schedule_id => js.id},
											 {:user_id => jason.id, :schedule_id => jmacs.id}])

CourseSelection.create(:scheduled_course_id => sc15210.id, :schedule_id => vs.id)
CourseSelection.create(:scheduled_course_id => sc15213.id, :schedule_id => vs.id)
CourseSelection.create(:scheduled_course_id => sc15396.id, :schedule_id => vs.id)
CourseSelection.create(:scheduled_course_id => sc21301.id, :schedule_id => vs.id)

CourseSelection.create(:scheduled_course_id => sc15210.id, :schedule_id => jmacs.id)
CourseSelection.create(:scheduled_course_id => sc15213.id, :schedule_id => jmacs.id)
CourseSelection.create(:scheduled_course_id => sc15396.id, :schedule_id => jmacs.id)
CourseSelection.create(:scheduled_course_id => sc21301.id, :schedule_id => jmacs.id)

CourseSelection.create(:scheduled_course_id => sc15210.id, :schedule_id => es.id)
CourseSelection.create(:scheduled_course_id => sc15396.id, :schedule_id => es.id)

CourseSelection.create(:scheduled_course_id => sc15396.id, :schedule_id => js.id)
CourseSelection.create(:scheduled_course_id => sc21301.id, :schedule_id => js.id)

puts "Completed successfully!"
