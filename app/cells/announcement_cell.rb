class AnnouncementCell < ApplicationCell

  def index
    @announcements = context.active_announcements_of_courses
    @ids = widget.courses && widget.courses.split(",").map(&:to_i) || [] 
    @has_content = @ids & @announcements.map{|obj| obj.context.id} != []

    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end

