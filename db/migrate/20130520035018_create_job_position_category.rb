class CreateJobPositionCategory < ActiveRecord::Migration
  tag :predeploy

  def self.up
    create_table :job_position_categories do |t|
      t.integer :account_id, :limit => 8
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :job_position_categories
  end
end
