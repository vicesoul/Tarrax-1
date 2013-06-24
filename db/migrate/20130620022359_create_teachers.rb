class CreateTeachers < ActiveRecord::Migration
  tag :predeploy
  def self.up
    create_table :teachers do |t|
      t.integer :account_id, :limit => 8
      t.integer :teacher_category_id, :limit => 8
      t.integer :teacher_rank_id, :limit => 8
      t.boolean :internal
      t.string :name
      t.string :sex, :limit => 6
      t.text :known_case
      t.text :specialty_intro
      t.date :birthday
      t.string :email
      t.string :mobile
      t.string :pay_amount

      t.timestamps
    end

    add_index :teachers, :account_id
    add_index :teachers, :teacher_category_id
    add_index :teachers, :teacher_rank_id
  end

  def self.down
    drop_table :teachers
  end
end
