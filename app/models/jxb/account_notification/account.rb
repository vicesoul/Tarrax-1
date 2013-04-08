module Jxb
  module AccountNotification
    module Account

      def announcements_with_sub_account_announcements
        accounts = [self, self.sub_accounts].flatten
        ::AccountNotification.find(:all, :conditions => ["account_id IN (?)", accounts], :order => 'start_at DESC')
      end

    end
  end
end
