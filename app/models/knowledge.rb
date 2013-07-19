class Knowledge < ActiveRecord::Base

  attr_accessible :case_repostory_id, :subject, :user_id, :user, :used_case_tpl_id, :used_case_issue_id, :source

  belongs_to :case_repostory
  belongs_to :user
  has_one :case_tpl, :as => :context
  belongs_to :used_case_tpl, :class_name => 'CaseTpl', :foreign_key => 'used_case_tpl_id'
  belongs_to :used_case_issue, :class_name => 'CaseIssue', :foreign_key => 'used_case_issue_id'

  custom_filter_for_cases_or_knowledges

  named_scope :search_as_student, lambda {|user_id|
    {
      :conditions => ["knowledges.workflow_state in ('accepted') or knowledges.user_id = ?", user_id] 
    }
  }

  module Source
    TEACHER = 'teacher'
    STUDENT = 'student'
    CASE_ISSUE = 'case_issue'
  end

  include Workflow

  workflow do
    state :new do
      event :submit, :transitions_to => :awaiting_review
      event :direct_accept, :transitions_to => :accepted
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

    def find_or_init_knowledge_tpl
      knowledge = self.new(:subject => t('#knowledges.model_init.knowledge', 'Knowledge'))
      tpl = knowledge.build_case_tpl(:name => t('#case_tpls.model_init.default_knowledge_tpl', 'Default knowledge template'))
      tpl.case_tpl_widgets.build(
        :title => t('#case_tpls.model_init.subject', 'Subject'),
        :body => t('#case_tpls.model_init.content', 'Content'),
        :seq => 0
      )
      knowledge
    end

    def init_pushed_knowledge knowledge, content
      tpl = knowledge.build_case_tpl(:name => t('#knowledges.model_init.default_tpl', 'Default Knowledge Template'), :user => knowledge.user)
      tpl.case_tpl_widgets.build(
        :title => knowledge.subject,
        :body => content,
        :seq => 0
      )
    end

    def display_state
      {
        'new' => t('#knowledges.state_array.new', 'New'),
        'awaiting_review' => t('#knowledges.state_array.awaiting_review', 'Awaiting Review'),
        'accepted' => t('#knowledges.state_array.accepted', 'Accepted'),
        'rejected' => t('#knowledges.state_array.rejected', 'Rejected')
      }
    end

    def display_source
      {
        self::Source::TEACHER => t('#knowledges.source.teacher', 'Teacher'),
        self::Source::STUDENT => t('#knowledges.source.student', 'Student'),
        self::Source::CASE_ISSUE => t('#knowledges.source.case_issue', 'Case Issue')
      } 
    end

  end

end
