module Jxb
  module CourseSystem
    module Course
      def self.included(base)
        base.class_eval do
          has_many :course_systems, :dependent => :destroy
          named_scope :of_account, lambda { |account|
            { :conditions => {:account_id => account} }
          }

          named_scope :of_job_position, lambda { |job_position|
            { :joins => :course_systems, :conditions => {:course_systems => {:job_position_id => job_position}} }
          }

          named_scope :of_course_category, lambda { |category|
            { :conditions => { :course_category_id => category} }
          }

        end
      end
    end
  end
end

