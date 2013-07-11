class CaseTpl < ActiveRecord::Base

  attr_accessible :context_id, :context_type, :name, :user, :user_id

  belongs_to :context, :polymorphic => true

  has_many :case_tpl_widgets, :dependent => :destroy, :order => 'seq'
  belongs_to :case_issue
  belongs_to :case_solution
  belongs_to :user
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:context_id, :context_type]

  named_scope :not_deleted, :conditions => ['workflow_state != ?', 'deleted']

  include Workflow

  workflow do 
    state :new do 
      event :remove, :transitions_to => :deleted
    end
    state :deleted
  end

  def self.init_case_tpl
    tpl = self.new(:name => t('#case_tpls.model_init.tpl', 'Case Tpl'))
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
    tpl
  end

end
