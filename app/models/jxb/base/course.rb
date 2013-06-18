module Jxb
  module Base
    module Course
      def self.included(base)
        base.class_eval do
          include Jxb::CourseSystem::Course
        end
      end
    end
  end
end


