class AddLearningPlanCourses < ActiveRecord::Migration
  tag :predeploy

  def self.up
    create_table :learning_plan_courses do |t|
      t.integer :learning_plan_id, :limit => 8
      t.integer :course_id, :limit => 8
    end

    add_index :learning_plan_courses, :learning_plan_id
    add_index :learning_plan_courses, :course_id
  end

  def self.down
    drop_table :learning_plan_courses
  end
end
