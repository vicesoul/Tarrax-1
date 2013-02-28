class AssignmentCell < ApplicationCell

  def index
    @assignments = context.active_assignments_of_courses(@opts[:courses])
    @ids = widget.courses && widget.courses.split(",").map(&:to_i) || [] 
    @has_content = @ids & @assignments.map{|obj| obj.context.id} != []

    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end

