class ChangeRoleToRoleNameForLeaningPlanUsers < ActiveRecord::Migration
  tag :predeploy

  def self.up
    rename_column :learning_plan_users, :role, :role_name
  end

  def self.down
    rename_column :learning_plan_users, :role_name, :role
  end
end
