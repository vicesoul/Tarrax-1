class AddLearningPlans < ActiveRecord::Migration
  tag :predeploy

  def self.up
    create_table :learning_plans do |t|
      t.integer :account_id, :limit => 8
      t.string :subject
      t.string :status
      t.date :start_on
      t.date :end_on
      t.datetime :published_at
    end

    add_index :learning_plans, :account_id
    add_index :learning_plans, :start_on
  end

  def self.down
    drop_table :learning_plans
  end
end
