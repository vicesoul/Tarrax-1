class CreateCaseTplWidgets < ActiveRecord::Migration
	tag :predeploy

  def self.up
    create_table :case_tpl_widgets do |t|
      t.integer :case_tpl_id, :limit => 8
      t.string :title
      t.text :body
      t.integer :seq
      t.timestamps
    end

    add_index :case_tpl_widgets, :case_tpl_id
  end

  def self.down
    drop_table :case_tpl_widgets
  end
end
