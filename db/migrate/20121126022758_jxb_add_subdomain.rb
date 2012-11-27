class AddSubdomain < ActiveRecord::Migration
  tag :predeploy

  def self.up
    create_table :subdomains do |t|
      t.integer :account_id, :limit => 8
      t.string  :subdomain
    end

    add_index :subdomains, :account_id
    add_index :subdomains, :subdomain
  end

  def self.down
    drop_table :subdomains
  end
end
