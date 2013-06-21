class AddMissingTimestampsForCourseSystem < ActiveRecord::Migration
  tag :predeploy
  def self.up
    add_column :course_systems, :created_at, :datetime
    add_column :course_systems, :updated_at, :datetime

    add_column :learning_plans, :created_at, :datetime
    add_column :learning_plans, :updated_at, :datetime

    add_column :learning_plan_courses, :created_at, :datetime
    add_column :learning_plan_courses, :updated_at, :datetime

    add_column :learning_plan_users, :created_at, :datetime
    add_column :learning_plan_users, :updated_at, :datetime

    CourseSystem.update_all ["created_at = :now, updated_at = :now", :now => Time.current]
    LearningPlan.update_all ["created_at = :now, updated_at = :now", :now => Time.current]
    LearningPlanCourse.update_all ["created_at = :now, updated_at = :now", :now => Time.current]
    LearningPlanUser.update_all ["created_at = :now, updated_at = :now", :now => Time.current]
  end

  def self.down
    remove_column :course_systems, :created_at
    remove_column :course_systems, :updated_at

    remove_column :learning_plans, :created_at
    remove_column :learning_plans, :updated_at

    remove_column :learning_plan_courses, :created_at
    remove_column :learning_plan_courses, :updated_at

    remove_column :learning_plan_users, :created_at
    remove_column :learning_plan_users, :updated_at
  end
end
