class CreateCaseIssues < ActiveRecord::Migration
	tag :predeploy

  def self.up
    create_table :case_issues do |t|
      t.integer :case_repostory_id, :limit => 8
      t.string :subject
      t.string :workflow_state
      t.integer :user_id, :limit => 8
      t.timestamps
    end
  
    add_index :case_issues, :case_repostory_id
    add_index :case_issues, :user_id
  end

  def self.down
    drop_table :case_issues
  end
end
