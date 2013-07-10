class CreateCaseTpls < ActiveRecord::Migration
	tag :predeploy

  def self.up
    create_table :case_tpls do |t|
      t.integer :context_id, :limit => 8
      t.string :context_type
      t.string :name
      t.string :workflow_state
      t.integer :user_id, :limit => 8
      t.timestamps
    end
  end

  def self.down
    drop_table :case_tpls
  end
end
