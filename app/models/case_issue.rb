class CaseIssue < ActiveRecord::Base

  attr_accessible :case_repostory_id, :subject, :user_id, :user
  belongs_to :case_repostory
  belongs_to :user
  has_many :case_solutions
  has_one :case_tpl, :as => :context

  include Workflow

  def self.find_or_init_case_tpl
    issue = self.new(:subject => t('#case_issues.model_init.issue', 'Case Issue'))
    tpl = issue.build_case_tpl(:name => t('#case_tpls.model_init.default_tpl', 'Default case issue template'))
    tpl.case_tpl_widgets.build(
      :title => t('#case_tpls.model_init.subject', 'Subject'),
      :body => t('#case_tpls.model_init.body', 'Content'),
      :seq => 0
    )
    tpl.case_tpl_widgets.build(
      :title => t('#case_tpls.model_init.content', 'Content'),
      :body => t('#case_tpls.model_init.body', 'Content'),
      :seq => 1
    )
    issue
  end

  workflow do
    state :new do
      event :submit, :transitions_to => :awaiting_review
    end
    state :awaiting_review do
      event :review, :transitions_to => :being_reviewed
    end
    state :being_reviewed do
      event :accept, :transitions_to => :accepted
      event :reject, :transitions_to => :rejected
    end
    state :accepted
    state :rejected
  end 
  
  class << self
    def display_state
      {
        'new' => t('#case_issues.state_array.new', 'New'),
        'awaiting_review' => t('#case_issues.state_array.awaiting_review', 'Awaiting Review'),
        'accepted' => t('#case_issues.state_array.accepted', 'Accepted'),
        'rejected' => t('#case_issues.state_array.rejected', 'Rejected')
      }
    end
  end

end
