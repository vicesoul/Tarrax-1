class JobPosition < ActiveRecord::Base

  belongs_to :job_position_category
  belongs_to :account
  has_many :user_account_associations

  validates_presence_of :code 
  validates_presence_of :name 
  validates_presence_of :account_id
  validates_presence_of :job_position_category_id
  validates_numericality_of :rank, :greater_than_or_equal_to => 0, :less_than => 31

end
