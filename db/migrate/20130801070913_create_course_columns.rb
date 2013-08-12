class CreateCourseColumns < ActiveRecord::Migration
  tag :predeploy

  def self.up
    create_table :course_columns do |t|
      t.integer :course_id, :limit => 8
      t.string :slug
      t.string :name
      t.text :content
      t.integer :position

      t.timestamps
    end

    add_index :course_columns, :course_id
    add_index :course_columns, :slug
  end

  def self.down
    drop_table :course_columns
  end
end
