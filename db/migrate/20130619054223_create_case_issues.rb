class CreateCaseIssues < ActiveRecord::Migration
	tag :predeploy

  def self.up
    create_table :case_issues do |t|
      t.integer :case_repostory_id, :limit => 8
      t.string :subject
      t.string :workflow_state
      t.string :group_discuss
      t.integer :user_id, :limit => 8
      t.timestamps
    end
  end

  def self.down
    drop_table :case_issues
  end
end
