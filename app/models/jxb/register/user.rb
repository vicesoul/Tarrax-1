module Jxb
  module Register
    module User
      def self.included(base)
        base.class_eval do
          apply_simple_captcha :message => :invalid_code
          attr_accessible :captcha, :captcha_key
        end
      end
    end
  end
end

