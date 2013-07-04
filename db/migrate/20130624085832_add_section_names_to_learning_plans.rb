class AddSectionNamesToLearningPlans < ActiveRecord::Migration
  tag :predeploy
  def self.up
    add_column :learning_plans, :section_names, :text
  end

  def self.down
    remove_column :learning_plans, :section_names
  end
end
