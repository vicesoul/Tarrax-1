class CaseRepostory < ActiveRecord::Base
  
  belongs_to :context, :polymorphic => true
  has_many :case_issues

  attr_accessible :context_id, :context_type, :name
  validates_uniqueness_of :name, :scope => [:context_id, :context_type]

end
