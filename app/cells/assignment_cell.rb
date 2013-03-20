class AssignmentCell < ApplicationCell

  def index
    @assignments = context.active_assignments_of_courses(@opts[:courses])
    format_contexts(@assignments)

    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end

