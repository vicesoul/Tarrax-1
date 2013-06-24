class Teacher < ActiveRecord::Base
  belongs_to :account
  belongs_to :teacher_category
  belongs_to :teacher_rank

  attr_accessible :account, :teacher_category, :teacher_rank, :internal, :name, :sex, :known_case, :specialty_intro, :birthday, :email, :mobile, :pay_amount
  attr_accessible :teacher_category_id, :teacher_rank_id

  validates_presence_of :name, :sex, :email, :teacher_category, :teacher_rank
end
