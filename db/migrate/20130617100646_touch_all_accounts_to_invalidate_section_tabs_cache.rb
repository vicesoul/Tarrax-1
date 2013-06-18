class TouchAllAccountsToInvalidateSectionTabsCache < ActiveRecord::Migration
  tag :predeploy

  def self.up
    # make all section_tabs cache expired
    Account.update_all ["updated_at = ?", Time.current]
  end

  def self.down
  end
end
