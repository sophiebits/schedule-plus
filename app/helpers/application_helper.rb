module ApplicationHelper
  def controller_stylesheet_link_tag
    stylesheet = "#{params[:controller]}.css"

    if File.exists?(File.join(Rails.public_path, 'stylesheets', stylesheet))
      stylesheet_link_tag stylesheet, :media => "all"
    end
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.merge(:sort => column, :direction => direction, :page => nil), 
                   :class => css_class
  end
end
