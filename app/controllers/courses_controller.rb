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
    semester = (Semester.find_by_short_name(params[:semester]) if params[:semester]) || current_semester
    @course = Course.by_semester(semester)
                    .find_by_number(params[:id]) or raise ActiveRecord::RecordNotFound 
  end

  private

  def sort_column
    Course.column_names.include?(params[:sort]) ? params[:sort] : "number"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
