class AddLearningPlanUsers < ActiveRecord::Migration
  tag :predeploy

  def self.up
    create_table :learning_plan_users do |t|
      t.integer :learning_plan_id, :limit => 8
      t.integer :user_id, :limit => 8
      t.string :role
    end

    add_index :learning_plan_users, :learning_plan_id
    add_index :learning_plan_users, :user_id
  end

  def self.down
    drop_table :learning_plan_users
  end
end
