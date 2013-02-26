class AnnouncementCell < ApplicationCell

  def index
    @announcements = context.active_announcements_of_courses
    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end

