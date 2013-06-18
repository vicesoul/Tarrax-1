module Jxb
  module CourseSystem
    module Account
      def self.included(base)
        base.class_eval do
          has_many :course_systems, :dependent => :destroy
          has_many :job_positions, :dependent => :destroy
          has_many :learning_plans, :dependent => :destroy
        end
      end
    end
  end
end

