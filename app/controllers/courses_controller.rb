class CoursesController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    @courses = Course.by_semester(current_semester)
                     .by_department(params[:department_id])
                     .search(params[:search])
                     .order(sort_column + " " + sort_direction)
                     .paginate(:per_page => 20, :page => params[:page])
  end

  def show
    @course = Course.by_semester(current_semester)
                    .find_by_number(params[:id])    
    
    # FIXME this should 404
    redirect_to courses_path if @course.nil?   
  end

  private

  def sort_column
    Course.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
