# encoding=UTF-8

class AddStudentFlagForFolder < ActiveRecord::Migration
  tag :predeploy

  def self.up
    add_column :folders, :is_student, :boolean, :default => false

    Folder.update_all({:is_student=>true}, {:full_name => 'system/student_folder'})

    Folder.update_all({:full_name => "course files/学生专用"}, {:full_name => 'system/student_folder'})
  end

  def self.down
    remove_column :folders, :is_student
  end
end
