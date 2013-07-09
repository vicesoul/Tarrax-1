class AddCaseAttributeForCourse < ActiveRecord::Migration
  tag :predeploy

  def self.up
    add_column :courses, :is_case, :boolean, :default => false

    Course.update_all({:is_case => false})
  end

  def self.down
    remove_column :courses, :is_case
  end
end
