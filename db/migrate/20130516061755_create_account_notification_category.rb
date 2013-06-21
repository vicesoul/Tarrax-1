class CreateAccountNotificationCategory < ActiveRecord::Migration
  tag :predeploy

  def self.up
    create_table :account_notification_categories do |t|
      t.integer :account_id, :limit => 8
      t.string :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :account_notifications, :account_notification_category_id, :integer, :limit => 8

  end

  def self.down
    drop_table :account_notification_categories
    remove_column :account_notifications, :account_notification_category_id 
  end
end
