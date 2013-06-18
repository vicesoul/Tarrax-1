class AddColumnsForStaffManagement < ActiveRecord::Migration
  tag :predeploy

  def self.up
    add_column :users, :birthday, :string
    add_column :users, :mobile_phone, :string

    add_column :user_account_associations, :job_number, :string
    add_column :user_account_associations, :job_position_id, :integer, :limit => 8
    # state => [:actived => 0, :be_frozen => 1, :frozen => 2]
    add_column :user_account_associations, :state, :integer, :default => 0, :limit => 1

    UserAccountAssociation.update_all(:state => 0)

  end

  def self.down
    remove_column :users, :birthday
    remove_column :users, :mobile_phone

    remove_column :user_account_associations, :job_number
    remove_column :user_account_associations, :job_position_id
    remove_column :user_account_associations, :state
  end

end
