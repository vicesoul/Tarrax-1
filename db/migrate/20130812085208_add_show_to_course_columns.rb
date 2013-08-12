class AddShowToCourseColumns < ActiveRecord::Migration
  tag :predeploy
  def self.up
    add_column :course_columns, :show, :boolean
  end

  def self.down
    remove_column :course_columns, :show
  end
end
