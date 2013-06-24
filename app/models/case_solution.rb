class CaseSolution < ActiveRecord::Base
  
  belongs_to :case_issue
  belongs_to :user

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

end
