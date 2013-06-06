class AddColumnForIframeForWidget < ActiveRecord::Migration
	tag :predeploy
  def self.up
    add_column :jxb_widgets, :iframe_url, :string 
  end
 
  def self.down
  	remove_column :jxb_widgets, :iframe_url
  end
end
