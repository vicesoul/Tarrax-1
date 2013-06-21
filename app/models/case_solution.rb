class CaseSolution < ActiveRecord::Base
  
  belongs_to :case_issue
  belongs_to :user
  has_one :case_tpl, :as => :context

  include Workflow

  workflow do 
    state :new do
      event :execute, :transitions_to => :executing
      event :group_discuss, :transitions_to => :pending
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
