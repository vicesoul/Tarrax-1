class CourseCell < ApplicationCell
  cache :index, :expires_in => 5.minutes

  def index
    @courses = account.fast_all_courses(:limit => 10)
    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end
