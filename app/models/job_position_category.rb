class JobPositionCategory < ActiveRecord::Base

  attr_accessible :account_id, :name

  has_many :job_positions
  belongs_to :account

  validates_presence_of :name
  validates_presence_of :account_id

end
