class LearningPlanCourse < ActiveRecord::Base
  attr_accessible :learning_plan, :course_id
  validates_presence_of :course

  belongs_to :learning_plan
  belongs_to :course
end
