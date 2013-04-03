module Jxb
  module Base
    module AccountUser
      def self.included(base)
        base.class_eval do
          include Jxb::Register::AccountUser
        end
      end
    end
  end
end


