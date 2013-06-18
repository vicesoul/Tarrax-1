module Jxb
  module CourseSystem
    module UserAccountAssociation
      def self.included(base)
        base.class_eval do
          belongs_to :job_position
          attr_accessible :source, :external, :job_position

          named_scope :of_root_account, lambda { |account|
            {
              :joins => :account,
              :conditions => ["accounts.root_account_id = ? OR accounts.id = ?", account.root_account.id, account.root_account.id]
            }
          }
        end
      end

    end
  end
end
