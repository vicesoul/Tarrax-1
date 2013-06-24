module Jxb
  module TeacherBank
    module Account
      def self.included(base)
        base.class_eval do
          has_many :teachers, :dependent => :destroy
          has_many :teacher_categories, :dependent => :destroy
          has_many :teacher_ranks, :dependent => :destroy
        end
      end
    end
  end
end

