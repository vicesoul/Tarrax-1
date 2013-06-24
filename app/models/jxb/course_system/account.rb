module Jxb
  module CourseSystem
    module Account
      def self.included(base)
        base.class_eval do
          has_many :course_systems, :dependent => :destroy
          has_many :job_positions, :dependent => :destroy
          has_many :learning_plans, :dependent => :destroy
        end
      end

      # batch associate exists users to account
      #
      # user_ids - id of users to be associated with current account
      # opts - options
      #
      # return 
      #   ture - succeed
      #   false - failed
      def attach_users user_ids, opts = {}
        special_associations = ::User.calculate_account_associations_from_accounts([self])
        ::User.update_account_associations(
          user_ids,
          :staff_attributes => {:source => 'created', :external => true},
          :incremental => true,
          :precalculated_associations => special_associations
        )
      end
    end
  end
end

