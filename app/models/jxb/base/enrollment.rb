module Jxb
  module Base
    module Enrollment
      def self.included(base)
        base.class_eval do
          include Jxb::CourseSystem::Enrollment
        end
      end
    end
  end
end


