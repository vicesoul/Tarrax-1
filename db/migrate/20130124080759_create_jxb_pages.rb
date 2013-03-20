class CreateJxbPages < ActiveRecord::Migration
  tag :predeploy
  
  def self.up
    create_table :jxb_pages do |t|
      t.string  :name
      t.string  :theme,      :default => "jiaoxuebang"
      t.integer :context_id, :limit => 8
      t.string  :context_type
      t.string  :courses
      t.string  :background_image

      t.timestamps
    end
  end

  def self.down
    drop_table :jxb_pages
  end
end
