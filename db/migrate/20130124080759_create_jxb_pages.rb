class CreateJxbPages < ActiveRecord::Migration
  tag :predeploy
  
  def self.up
    create_table :jxb_pages do |t|
      t.string  :name
      t.string  :theme,      :default => "jxb"
      t.integer :context_id, :limit => 8
      t.string  :context_type
      t.string  :accounts

      t.timestamps
    end
  end

  def self.down
    drop_table :jxb_pages
  end
end
