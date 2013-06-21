class CaseIssue < ActiveRecord::Base

  belongs_to :case_repostory
  belongs_to :user
  has_one :case_tpl, :as => :context

  include Workflow

  def self.find_or_init_case_tpl
    issue = self.new(:subject => 'Case Issue')
    tpl = issue.build_case_tpl(:name => 'Default case issue template')
    tpl.case_tpl_widgets.build(
      :title => t('', 'Subject'),
      :body => t('', 'Subject body'),
      :seq => 0
    )
    tpl.case_tpl_widgets.build(
      :title => t('', 'Content'),
      :body => t('', 'Content body'),
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
  
end
