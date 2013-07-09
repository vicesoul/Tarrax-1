class CreateCaseRepostories < ActiveRecord::Migration
	tag :predeploy
  
  def self.up
    create_table :case_repostories do |t|
      t.integer :context_id, :limit => 8
      t.string :context_type
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :case_repostories
  end
end
