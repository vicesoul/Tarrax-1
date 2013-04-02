module Jxb
  module Base
    module Account
      def self.included(base)
        base.class_eval do
          include Jxb::Register::Account
        end
      end

      def default?
        ::Account.default == self
      end
    end
  end
end
