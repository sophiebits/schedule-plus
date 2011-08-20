class SchedulesController < ApplicationController
  def import
    @schedule = Parser.parse(params[:url])
    # store imported schedule id in session var to retrieve after oauth
    session[:imported] = @schedule.id
    if request.xhr?
      render :json => @schedule.to_json(:include =>
        {:scheduled_courses => {:include =>
            {
              :course => {}, 
              :lecture => {:include => :lecture_section_times}, 
              :recitation => {:include => :recitation_section_times}
            }
        }
      })
    else
      redirect_to schedules_path
    end
  end
  
  def new
    # release 2
  end

  def show
    if (!params[:id]) 
      if current_user
        @schedule = current_user.main_schedule
      else
        redirect_to root_path
      end
    else
      @schedule = Schedule.find(params[:id])
      if request.xhr?
        render :json => @schedule.to_json(:include =>
          {:scheduled_courses => {:include =>
             {
               :course => {}, 
               :lecture => {:include => :lecture_section_times}, 
               :recitation => {:include => :recitation_section_times}
             }
          }
        })
      else
        
      end
    end
  end

	def get_friends_in_course
		if request.xhr?
			scheduled_course_id = params[:scheduled_course_id]
			course_id = params[:course_id]

			friends_includes = friends.includes(:main_schedule => {:scheduled_courses => [:course]})
			if scheduled_course_id
				render :json => friends_includes.where('scheduled_courses.id = ?', scheduled_course_id).to_json
		elsif course_id
				render :json => friends_includes.where('courses.id = ?', course_id).to_json
			end
		else
			redirect_to schedules_path
		end
	end

  def add_course
    if request.xhr?
      input = params[:course]
      letter = input[5..-1]
      number = input[0,5]
      
      course = Course.find_by_number(number)
      section = course.find_by_section(letter)
p "COURSE " + course.number
p "SECTION " + section.section

      if course.lectures.find_by_section(letter)
        @course = ScheduledCourse.find_or_create_by_course_id_and_lecture_id(
          :course_id => course.id, :lecture_id => section.id)
      else
        @course = ScheduledCourse.find_or_create_by_course_id_and_lecture_id_and_recitation_id(
          :course_id => course.id, :lecture_id => section.lecture.id, :recitation_id => section.id)
      end

      CourseSelection.create(:schedule_id => current_user.main_schedule.id, :scheduled_course_id => @course.id)
      render :json => @course.to_json(:include => {
        :course => {},
        :lecture => { :include => :lecture_section_times },
        :recitation => { :include => :recitation_section_times }
      })
    else

    end
  end
end
