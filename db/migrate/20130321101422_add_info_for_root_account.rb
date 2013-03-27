class AddInfoForRootAccount < ActiveRecord::Migration
  tag :predeploy

  def self.up
    add_column :account_users, :role, :string
    add_column :account_users, :mobile, :string

    add_column :accounts, :school_category, :string
    add_column :accounts, :school_scale, :string
  end

  def self.down
    remove_column :account_users, :role, :string
    remove_column :account_users, :mobile, :string

    remove_column :accounts, :school_category, :string
    remove_column :accounts, :school_scale, :string
  end
end
