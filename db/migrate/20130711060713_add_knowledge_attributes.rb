class AddKnowledgeAttributes < ActiveRecord::Migration
  tag :predeploy

  def self.up
    # sub_type => ['case_issue', 'knowledge']
    add_column :courses, :sub_type, :string
    # sub_type => ['case_issue', 'knowledge']
    add_column :case_tpls, :sub_type, :string
    # sub_type => ['case_issue', 'knowledge']
    add_column :case_repostories, :sub_type, :string

    Course.update_all("sub_type='case_issue'", 'is_case = true')
    CaseTpl.update_all("sub_type = 'case_issue'", 'sub_type is null')
    CaseRepostory.update_all("sub_type = 'case_issue'", 'sub_type is null')
    remove_column :courses, :is_case
  end

  def self.down
    remove_column :courses, :sub_type
    remove_column :case_tpls, :sub_type
    remove_column :case_repostories, :sub_type
  end
end
