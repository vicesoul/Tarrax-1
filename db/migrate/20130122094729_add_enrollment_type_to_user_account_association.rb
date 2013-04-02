class AddEnrollmentTypeToUserAccountAssociation < ActiveRecord::Migration
  tag :predeploy

  def self.up
    add_column :user_account_associations, :enrollment_type, :string
    add_column :user_account_associations, :fake, :boolean
  end

  def self.down
    remove_column :user_account_associations, :enrollment_type
    remove_column :user_account_associations, :fake, :boolean
  end
end
