class CreateCaseSolutions < ActiveRecord::Migration
	tag :predeploy

  def self.up
    create_table :case_solutions do |t|
      t.integer :case_issue_id, :limit => 8
      t.string :workflow_state
      t.integer :user_id, :limit => 8
      t.timestamps
    end
  end

  def self.down
    drop_table :case_solutions
  end
end
