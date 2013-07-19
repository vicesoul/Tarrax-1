module KnowledgesHelper

  def display_knowledge_state text, state
    begin
      case state.to_sym
      when :new
        "<span class='label'>#{text}</span>"
      when :awaiting_review
        "<span class='label label-warning'>#{text}</span>"
      when :accepted
        "<span class='label label-success'>#{text}</span>"
      when :rejected
        "<span class='label label-important'>#{text}</span>"
      end
    end.html_safe
  end

end
