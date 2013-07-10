class AddCaseTplAssociationForCaseIssue < ActiveRecord::Migration
  tag :predeploy

  def self.up
    add_column :case_issues, :used_case_tpl_id, :integer, :limit => 8
  end

  def self.down
    remove_column :case_issues, :used_case_tpl_id
  end
end
