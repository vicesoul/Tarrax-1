class CreateCaseSolutions < ActiveRecord::Migration
	tag :predeploy

  def self.up
    create_table :case_solutions do |t|
      t.integer :case_issue_id, :limit => 8
      t.string :workflow_state
      t.boolean :group_discuss, :limit => false
      t.integer :user_id, :limit => 8
      t.string :title
      t.text :content
      t.timestamps
    end

    add_index :case_solutions, :case_issue_id
    add_index :case_solutions, :user_id 
  end

  def self.down
    drop_table :case_solutions
  end
end
