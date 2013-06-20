module Jxb
  module CourseSystem
    module Enrollment
      def self.included(base)
        base.class_eval do
          belongs_to :learning_plan
          attr_accessible :learning_plan
        end
      end
    end
  end
end


