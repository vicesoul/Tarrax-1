class JobPosition < ActiveRecord::Base

  attr_accessible :account_id, :job_position_category_id, :code, :name, :rank, :source

  belongs_to :job_position_category
  belongs_to :account
  has_many :user_account_associations

  # skipping some validations such as sis_import
  attr_accessor :source

  validates_presence_of :code, :if => Proc.new { |jp| jp.source.blank? }
  validates_presence_of :name 
  validates_presence_of :account_id
  validates_presence_of :job_position_category_id, :if => Proc.new { |jp| jp.source.blank? }

  validates_numericality_of :rank, :greater_than_or_equal_to => 0, :less_than => 31, :if => Proc.new { |jp| jp.source.blank? }

end
