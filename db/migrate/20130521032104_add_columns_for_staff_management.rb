class AddColumnsForStaffManagement < ActiveRecord::Migration
  tag :predeploy

  def self.up
    add_column :users, :birthday, :string
    add_column :users, :mobile_phone, :string

    add_column :user_account_associations, :job_number, :string
    add_column :user_account_associations, :job_position_id, :integer, :limit => 8
    # state => [:actived => 0, :be_frozen => 1, :frozen => 2]
    add_column :user_account_associations, :state, :integer, :default => 0, :limit => 1

    create_table :user_account_association_change_logs do |t|
      t.integer :user_account_association_id, :limit => 8
      t.string :state_from
      t.string :state_to
      t.integer :operation_user_id, :limit => 8
      t.timestamps
    end

    UserAccountAssociation.update_all(:state => 0)

  end

  def self.down
    remove_column :users, :birthday
    remove_column :users, :mobile_phone

    remove_column :user_account_associations, :job_number
    remove_column :user_account_associations, :job_position_id
    remove_column :user_account_associations, :state

    drop_table :user_account_association_change_logs
  end

end
