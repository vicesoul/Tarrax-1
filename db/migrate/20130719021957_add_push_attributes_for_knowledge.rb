class AddPushAttributesForKnowledge < ActiveRecord::Migration
  tag :predeploy

  def self.up
    add_column :knowledges, :used_case_issue_id, :integer, :limit => 8
    add_column :knowledges, :source, :string
  end

  def self.down
    remove_column :knowledges, :used_case_issue_id
    remove_column :knowledges, :source
  end
end
