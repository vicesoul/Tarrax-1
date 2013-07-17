class CreateKnowledges < ActiveRecord::Migration
	tag :predeploy

  def self.up
    create_table :knowledges do |t|
      t.integer :case_repostory_id, :limit => 8
      t.string :subject
      t.string :workflow_state
      t.integer :user_id, :limit => 8
      t.integer :used_case_tpl_id, :limit => 8
      t.timestamps
    end

    add_index :knowledges, :case_repostory_id
    add_index :knowledges, :user_id
    add_index :knowledges, :used_case_tpl_id

  end

  def self.down
    drop_table :knowledges
  end
end
