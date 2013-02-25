class AssignmentCell < ApplicationCell

  def index
    @assignments = context.active_assignments_of_courses(@opts[:courses])
    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end

