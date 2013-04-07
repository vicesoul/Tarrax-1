class CreateCourseCategory < ActiveRecord::Migration
  tag :predeploy

  def self.up
      create_table :course_categories do |t|
        t.string :name
      end
  end

  def self.down
      drop_table :course_categories
  end
end
