module Jxb
  module PickupAndSelect
    module Account
      def self.included(base)
        base.extend(ClassModules)
      end

      def sub_accounts_as_tree_with_user_emails(preloaded_accounts = nil)
        unless preloaded_accounts
          preloaded_accounts = {}
          self.root_account.all_accounts.active.each do |account|
            (preloaded_accounts[account.parent_account_id] ||= []) << account
          end
        end
        user_emails = self.all_users.map{|u| u.email}
        title = "<a href='javascript:void(0)' class='node-title' id='account_#{self.id}'><ins>&nbsp;</ins>#{self.name}(#{user_emails.size})</a>".html_safe
        res = [{ :label => title, :id => self.id, :children => [] }]
        if preloaded_accounts[self.id]
          preloaded_accounts[self.id].each do |account|
            res[0][:children] += account.sub_accounts_as_tree_with_user_emails(preloaded_accounts)
          end
        end
        res
      end

      module ClassModules
        def all_users_with_ids(ids = [])
          return [] if ids.blank?
          ::User.find(:all,
                    :conditions => [ "user_account_associations.account_id IN (?)", ids ],
                    :include => [:associated_accounts],
                    :select => "DISTINCT id"
                   )
        end
      end # End of ClassModules

    end
  end
end
