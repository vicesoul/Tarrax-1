class JxbRenameSubdomainToNameInSubdomains < ActiveRecord::Migration
  tag :predeploy

  def self.up
    rename_column :subdomains, :subdomain, :name
    rename_index :subdomains, 'index_subdomains_on_subdomain', 'index_subdomains_on_name'
  end

  def self.down
    rename_column :subdomains, :name, :subdomain
    rename_index :subdomains, 'index_subdomains_on_name', 'index_subdomains_on_subdomain'
  end
end
