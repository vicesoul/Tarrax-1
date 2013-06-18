class CreateJobPosition < ActiveRecord::Migration
  tag :predeploy

  def self.up
    create_table :job_positions do |t|
      t.integer :account_id, :limit => 8
      t.integer :job_position_category_id, :limit => 8
      t.string :code
      t.string :name
      t.integer :rank, :limit => 2
      t.timestamps
    end
    
    add_index :job_positions, :account_id
    add_index :job_positions, :job_position_category_id
  end

  def self.down
    drop_table :job_positions
  end
end
