class CoursesController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    @courses = Course.search(params[:search])
                     .order(sort_column + " " + sort_direction)
                     .paginate(:per_page => 2, :page => params[:page])
  end

  def show
    
  end

  private

  def sort_column
    Course.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
