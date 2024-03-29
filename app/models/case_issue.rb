class CaseIssue < ActiveRecord::Base

  attr_accessible :case_repostory_id, :subject, :user_id, :user, :used_case_tpl_id
  belongs_to :case_repostory
  belongs_to :user
  has_many :case_solutions, :dependent => :destroy
  has_one :case_tpl, :as => :context
  has_one :knowledge, :foreign_key => 'used_case_issue_id'
  belongs_to :used_case_tpl, :class_name => 'CaseTpl', :foreign_key => 'used_case_tpl_id'

  custom_filter_for_cases_or_knowledges

  #after_save :broadcast_notifications

  #has_a_broadcast_policy

  #set_broadcast_policy do |p|
    #p.dispatch :case_issue_awaiting_review
    #p.to {
      #User.find(:all) 
    #}
    #p.whenever { |record|
      #record.awaiting_review? 
    #}
  #end

  def is_documented_by_knowledge_base?
    self.knowledge && self.knowledge.accepted?
  end

  def has_accepted_solutions?
    self.accepted? && self.case_solutions.any?{|s| s.accepted? }   
  end

  def push_to_knowledge_base knowledge_base_id, user
    knowledge_content = ''
    issue_subject = "<div>#{self.subject}</div>" 
    issue_content = self.case_tpl.case_tpl_widgets.inject(""){|r,o| r << o.body}

    solutions = self.case_solutions.select{ |s| s.accepted? }.inject(""){|r,o| r << "<div></div>#{o.title}" << o.content}

    knowledge_content << issue_subject << issue_content << solutions

    knowledge = Knowledge.new(:subject => self.subject, :case_repostory_id => knowledge_base_id, :user => user, :source => Knowledge::Source::CASE_ISSUE, :used_case_issue_id => self.id)
    Knowledge.init_pushed_knowledge(knowledge, knowledge_content)
    knowledge.save! and knowledge.submit
  end

  include Workflow

  
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

    def find_or_init_case_tpl
      issue = self.new(:subject => t('#case_issues.model_init.issue', 'Case Issue'))
      tpl = issue.build_case_tpl(:name => t('#case_tpls.model_init.default_tpl', 'Default case issue template'))
      tpl.case_tpl_widgets.build(
        :title => t('#case_tpls.model_init.subject', 'Subject'),
        :body => t('#case_tpls.model_init.content', 'Content'),
        :seq => 0
      )
      tpl.case_tpl_widgets.build(
        :title => t('#case_tpls.model_init.subject', 'Subject'),
        :body => t('#case_tpls.model_init.content', 'Content'),
        :seq => 1
      )
      issue
    end

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
