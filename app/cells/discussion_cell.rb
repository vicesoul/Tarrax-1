class DiscussionCell < ApplicationCell

  def index
    @discussions = context.active_discussions_of_courses(@opts[:courses])
    @ids = widget.courses && widget.courses.split(",").map(&:to_i) || [] 
    @has_content = @ids & @discussions.map{|obj| obj.context.id} != []

    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end
