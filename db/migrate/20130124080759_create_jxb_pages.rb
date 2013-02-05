class CreateJxbPages < ActiveRecord::Migration
  tag :predeploy
  
  def self.up
    create_table :jxb_pages do |t|
      t.string  :name
      t.string  :theme,      :default => "jxb"
      t.integer :account_id, :limit => 8

      t.timestamps
    end
  end

  def self.down
    drop_table :jxb_pages
  end
end
