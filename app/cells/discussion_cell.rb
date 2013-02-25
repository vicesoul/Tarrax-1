class DiscussionCell < ApplicationCell

  def index
    @discussions = context.active_discussions_of_courses(@opts[:courses])
    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end
