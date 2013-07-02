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
        # filter already associated user ids
        user_ids = user_ids.select {|uid| user_account_associations.find_by_user_id(uid).nil? }

        # do nothing if empty
        return [] if user_ids.empty?

        special_associations = ::User.calculate_account_associations_from_accounts([self])
        ::User.update_account_associations(
          user_ids,
          :staff_attributes => {:source => 'created', :external => true},
          :incremental => true,
          :precalculated_associations => special_associations
        )

        return user_ids
      end
    end
  end
end

