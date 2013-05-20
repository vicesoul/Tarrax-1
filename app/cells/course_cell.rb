class CourseCell < ApplicationCell
  helper :avatar
  
  def index
    @courses = context.fast_all_courses.select{|c| c.workflow_state == 'available'}
    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end
