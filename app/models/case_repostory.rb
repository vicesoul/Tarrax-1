class CaseRepostory < ActiveRecord::Base
  
  belongs_to :context, :polymorphic => true
  has_many :case_issues

  validates_uniqueness_of :name, :scope => [:context_id, :context_type]

end
