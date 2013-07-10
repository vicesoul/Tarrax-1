class AddCaseSolutionsIdForGroup < ActiveRecord::Migration
  tag :predeploy

  def self.up
    add_column :groups, :case_solution_id, :integer, :limit => 8
  end

  def self.down
    remove_column :groups, :case_solution_id
  end
end
