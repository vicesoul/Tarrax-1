class CaseSolution < ActiveRecord::Base
  
  attr_accessible :case_issue_id, :case_issue, :group_discuss, :user_id, :user, :title, :content

  belongs_to :case_issue
  belongs_to :user
  has_one :group, :dependent => :destroy

  validates_presence_of :title, :on => :update 
  validates_presence_of :content, :on => :update 
  validates_uniqueness_of :user_id, :scope => :case_issue_id, :message => 'You already applied this case issue.'

  include Workflow

  workflow do 
    state :new do
      event :execute, :transitions_to => :executing
      event :group_discuss_necessary, :transitions_to => :pending
    end

    state :pending do 
      event :execute, :transitions_to => :executing
    end

    state :executing do
      event :submit, :transitions_to => :being_reviewed
    end

    state :being_reviewed do
      event :review, :transitions_to => :reviewed
      event :recommend, :transitions_to => :recommended
    end
    
    state :reviewed
    state :recommended
  end

  def copy_solution_to_knowledge_base knowledge_base_id, user
    knowledge_content = ''
    issue_subject = "<div>#{self.case_issue.subject}</div>" 
    issue_content = self.case_issue.case_tpl.case_tpl_widgets.inject(""){|r,o| r << o.body}
    solution_title = "<div>#{self.title}</div>"
    knowledge_content << issue_subject << issue_content << solution_title << self.content

    knowledge = Knowledge.new(:subject => self.title, :case_repostory_id => knowledge_base_id, :user => user)
    Knowledge.init_pushed_knowledge(knowledge, knowledge_content)
    knowledge.save! and knowledge.direct_accept
  end

  class << self
    def display_state
      {
        'executing' => t('#case_solutions.state_array.executing', 'Executing'),
        'being_reviewed' => t('#case_solutions.state_array.being_reviewed', 'Being reviewed'),
        'reviewed' => t('#case_solutions.state_array.reviewed', 'Reviewed'),
        'recommended' => t('#case_solutions.state_array.recommended', 'Recommended')
      }
    end
  end
end
