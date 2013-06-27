class TeacherRank < ActiveRecord::Base
  belongs_to :account
  has_many :teachers

  attr_accessible :name, :account

  validates_presence_of :name
end
