class SchedulesController < ApplicationController
  def new
    
  end
  
  def import
    if params[:import]
      # Parse uploaded .ics file
      file = params[:import][:uploaded_file].tempfile
      parsed = Parser.parseSIO(file)   
    else
      # Parse scheduleman url
      parsed = Parser.parse(params[:url])
    end
    
    if current_user
      # authenticated, update active_schedule
      current_user.update_active_schedule(parsed[:schedule])
    else
      # store imported schedule id in session var to retrieve after oauth
      session[:imported] = parsed[:schedule].id
    end

    if request.xhr?
      render :json => parsed
    else
      redirect_to '/schedules/' + session[:imported].to_s
    end
  end

  def show
    if current_user && !current_user.main_schedule
      redirect_to new_schedules_path if request.env['PATH_INFO'] != new_schedules_path
    end
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
			scheduled_course_id = params[:scheduled_course_id].to_i
			course_id = params[:course_id].to_i

			friends_includes = friends.includes(:main_schedule => {:scheduled_courses => 
        [:course]})
			
      # if scheduled_course_id
        response = Hash.new
        response[:data] = Hash.new

        response[:data][:same_section] = friends_includes.where('scheduled_courses.id = ?', scheduled_course_id).order('users.name')
        response[:data][:other_section] = friends_includes.where('courses.id = ? AND scheduled_courses.id <> ?', course_id, scheduled_course_id).order('users.name')
        
        response[:me] = Hash.new
        if current_user.main_schedule.scheduled_courses.exists? scheduled_course_id
          response[:me][:same_section] = current_user
        elsif current_user.main_schedule.scheduled_courses.collect{|sc| sc.course_id}.include? course_id
          response[:me][:other_section] = current_user
        end

        render :json => response.to_json
      #       elsif course_id
      #   render :json => friends_includes.where('courses.id = ?', course_id).order('users.name').to_json
      # end

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
