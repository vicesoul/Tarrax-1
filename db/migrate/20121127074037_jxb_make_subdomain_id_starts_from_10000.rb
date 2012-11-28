class JxbMakeSubdomainIdStartsFrom10000 < ActiveRecord::Migration
  tag :predeploy

  def self.up
    case ActiveRecord::Base.configurations[RAILS_ENV]['adapter']
    when 'postgresql'
      execute "SELECT setval('subdomains_id_seq', 10000)"
    when 'mysql', 'mysql2'
      execute "ALTER TABLE subdomains INCREMENT = 10000"
    end
  end

  def self.down
  end
end
