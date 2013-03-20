class DiscussionCell < ApplicationCell
  helper :avatar

  def index
    @discussions = context.active_discussions_of_courses(@opts[:courses])
    format_contexts(@discussions)

    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end
