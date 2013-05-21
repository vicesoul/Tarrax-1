
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe JobPosition do
  
  before :each do 
    @account = Account.create
    @category = JobPositionCategory.create(
      :name => 'foo',
      :account_id => @account.id
    )

    @job_position_attributes = {
      :name => 'foo',
      :account_id => @account.id,
      :job_position_category_id => @category.id,
      :code => 'code',
      :rank => 0
    }
  end
  
  it "should validate presence of name" do
    lambda { JobPosition.create!(@job_position_attributes.delete_if{|k| k == :name}) }.should raise_error
  end

  it "should validate presence of account_id" do 
    lambda { JobPosition.create!(@job_position_attributes.delete_if {|k| k == :account_id })}.should raise_error
  end

  it "should validate presence of job_position_category_id" do 
    lambda { JobPosition.create!(@job_position_attributes.delete_if {|k| k == :job_position_category_id}) }.should raise_error
  end

  it "should validate presence of code" do 
    lambda { JobPosition.create!(@job_position_attributes.delete_if {|k| k == :code}) }.should raise_error
  end

  it "should validate range of rank for negative" do
    lambda { JobPosition.create!(@job_position_attributes.merge(:rank => -1)) }.should raise_error
  end
  
  it "should validate range of rank for more than 30" do
    lambda { JobPosition.create!(@job_position_attributes.merge(:rank => 31)) }.should raise_error
  end

  it "should validate range of rank for equals 30" do
    lambda { JobPosition.create!(@job_position_attributes.merge(:rank => 30)) }.should_not raise_error
  end

  it "should validate range of rank for Non-numeric" do
    lambda { JobPosition.create!(@job_position_attributes.merge(:rank => 'A')) }.should raise_error
  end
end
