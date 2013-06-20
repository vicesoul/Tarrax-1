module Jxb
  module Base
    module UserAccountAssociation
      def self.included(base)
        base.class_eval do
          include Jxb::CourseSystem::UserAccountAssociation
        end
      end
    end
  end
end

