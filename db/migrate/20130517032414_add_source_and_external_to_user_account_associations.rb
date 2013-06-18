class AddSourceAndExternalToUserAccountAssociations < ActiveRecord::Migration
  tag :predeploy

  def self.up
    add_column :user_account_associations, :source, :string
    add_column :user_account_associations, :external, :boolean
    UserAccountAssociation.update_all ['source = ?, external = ?', 'invited', true]
  end

  def self.down
    remove_column :user_account_associations, :external
    remove_column :user_account_associations, :source
  end
end
