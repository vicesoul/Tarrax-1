class AddCourseSystems < ActiveRecord::Migration
  tag :predeploy

  def self.up
    create_table :course_systems do |t|
      t.integer :account_id      , :limit => 8
      t.integer :course_id       , :limit => 8
      t.integer :job_position_id , :limit => 8
      t.string :rank
    end

    add_index :course_systems, :account_id
  end

  def self.down
    drop_table :course_systems
  end
end
