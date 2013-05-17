class AddCourseCategory < ActiveRecord::Migration
    tag :predeploy

    def self.up
        add_column :courses, :course_category_id, :integer, :limit => 8
    end

    def self.down
        remove_column :courses, :course_category_id
    end
end
