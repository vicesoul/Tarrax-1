module CaseIssuesHelper

  def get_issue_knowledge_state issue
    unless issue.knowledge.blank?
      Knowledge.display_state[issue.knowledge.workflow_state]
    else
      '-'
    end
  end

end
