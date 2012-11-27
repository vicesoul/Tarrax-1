class JxbMakeSubdomainIdStartsFrom10000 < ActiveRecord::Migration
  tag :predeploy

  def self.up
    # make next id started from 10000
    execute <<-SQL
      INSERT INTO SUBDOMAINS (id, account_id, subdomain) VALUES (9999, 1, 'ed9999');
    SQL

    # delete the row created above
    execute <<-SQL
      DELETE FROM SUBDOMAINS WHERE id = 9999;
    SQL
  end

  def self.down
  end
end
