
class CourseCategory < ActiveRecord::Base
    has_many :courses

    attr_accessible :name, :used

    def self.getAllCategoriesForIndex
        find(:all, :conditions => ['used != 0'])
    end
end
