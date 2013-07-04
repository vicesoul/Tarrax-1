class ChangeSectionNamesToSectionMappingsForLearningPlans < ActiveRecord::Migration
  tag :predeploy

  def self.up
    rename_column :learning_plans, :section_names, :section_mappings
  end

  def self.down
    rename_column :learning_plans, :section_mappings, :section_names
  end
end
