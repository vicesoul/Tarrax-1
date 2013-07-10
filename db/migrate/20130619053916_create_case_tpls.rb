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

    add_index :case_tpls, :user_id
    add_index :case_tpls, [:context_id, :context_type] 
  end

  def self.down
    drop_table :case_tpls
  end
end
