class ChangeStatusToWorkflowStateForLearningPlans < ActiveRecord::Migration
  tag :predeploy

  def self.up
    rename_column :learning_plans, :status, :workflow_state
  end

  def self.down
    rename_column :learning_plans, :workflow_state, :status
  end
end
