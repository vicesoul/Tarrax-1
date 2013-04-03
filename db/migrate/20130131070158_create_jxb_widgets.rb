class CreateJxbWidgets < ActiveRecord::Migration
  tag :predeploy

  def self.up
    create_table :jxb_widgets do |t|
      t.string :cell_name
      t.string :cell_action
      t.string :title
      t.text :body
      t.string :position
      t.integer :seq
      t.integer :page_id, :limit => 8
      t.string :courses

      t.timestamps
    end
  end

  def self.down
    drop_table :jxb_widgets
  end
end
