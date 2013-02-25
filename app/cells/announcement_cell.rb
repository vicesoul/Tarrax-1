class AnnouncementCell < ApplicationCell

  def index
    @announcements = account.active_announcements
    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end

