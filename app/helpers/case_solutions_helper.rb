module CaseSolutionsHelper

  def display_state text, state
    begin
      case state.to_sym
      when :executing
        "<span class='label'>#{text}</span>"
      when :being_reviewed
        "<span class='label label-warning'>#{text}</span>"
      when :remodified
        "<span class='label label-info'>#{text}</span>"
      when :accepted
        "<span class='label label-success'>#{text}</span>"
      when :rejected
        "<span class='label label-important'>#{text}</span>"
      end
    end.html_safe
  end

end
