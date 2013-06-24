class CreateTeacherCategories < ActiveRecord::Migration
  tag :predeploy
  def self.up
    create_table :teacher_categories do |t|
      t.integer :account_id, :limit => 8
      t.string :name

      t.timestamps
    end

    add_index :teacher_categories, :account_id
  end

  def self.down
    drop_table :teacher_categories
  end
end
