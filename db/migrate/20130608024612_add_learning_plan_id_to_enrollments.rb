class AddLearningPlanIdToEnrollments < ActiveRecord::Migration
  tag :predeploy

  def self.up
    add_column :enrollments, :learning_plan_id, :integer, :limit => 8
  end

  def self.down
    remove_column :enrollments, :learning_plan_id
  end
end
