module Jxb
  module Base
    module Account
      def self.included(base)
        base.class_eval do
          include Jxb::Register::Account
          include Jxb::Homepage::Account
          include Jxb::AccountNotification::Account
          include Jxb::PickupAndSelect::Account
          include Jxb::CourseSystem::Account
          include Jxb::TeacherBank::Account
        end
      end

      def default?
        ::Account.default == self
      end
    end
  end
end
