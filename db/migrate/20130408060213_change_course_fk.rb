class ChangeCourseFk < ActiveRecord::Migration
    tag :predeploy

    def self.up
        change_column :courses, :course_category_id, :integer
    end

    def self.down
    end
end
