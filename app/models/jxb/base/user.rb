module Jxb
  module Base
    module User
      def self.included(base)
        base.class_eval do
          include Jxb::Register::User
          include Jxb::Homepage::User
        end
      end

      def site_admin?
        ::Account.site_admin.account_users_for(self).any? {|i| i.membership_type == 'AccountAdmin'}
      end

      def jxb_admin?
        ::Account.default.account_users_for(self).any? {|i| i.membership_type == 'AccountAdmin'}
      end
    end
  end
end

