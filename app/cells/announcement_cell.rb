class AnnouncementCell < ApplicationCell
  helper :avatar

  def index
    @announcements = context.active_announcements_of_courses
    format_contexts(@announcements)

    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

  def account
    @announcements = @opts[:announcements] || context.announcements_with_sub_account_announcements

    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end
