class AddColumnForCourseCategory< ActiveRecord::Migration
    tag :predeploy

    def self.up
        add_column :course_categories, :used, :integer, :default => 0

        change_column_used_to_default
    end

    def self.change_column_used_to_default
        CourseCategory.update_all("used=0")
    end

    #ingore
    def self.down
    end
end
