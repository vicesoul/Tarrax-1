class CaseTpl < ActiveRecord::Base

  belongs_to :context, :polymorphic => true

  has_many :case_tpl_widgets, :dependent => :destroy, :order => 'seq'
  belongs_to :case_issue
  belongs_to :case_solution
  belongs_to :user
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:context_id, :context_type]

  def self.init_case_tpl
    tpl = self.new(:name => t('', 'Case Tpl'))
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
    tpl
  end

end
