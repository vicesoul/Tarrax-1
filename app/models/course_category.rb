
class CourseCategory < ActiveRecord::Base
    has_many :courses

    def self.getAllCategoriesForIndex
        find(:all, :conditions => ['used != 0'])
    end
end
