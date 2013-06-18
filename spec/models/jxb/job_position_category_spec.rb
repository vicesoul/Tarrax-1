
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe JobPositionCategory do
  
  before :each do 
    @account = Account.create
  end

  it "should validate presence of name" do 
    lambda { JobPositionCategory.create!(:account_id => @account.id) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should validate presence of account_id" do 
    lambda { JobPositionCategory.create!(:name => 'foo') }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should validate presence of name and account_id" do
    lambda { JobPositionCategory.create! }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should be created" do 
    lambda { JobPositionCategory.create!(:name => 'foo', :account_id => @account.id )}.should_not raise_error
  end

  it "should get category list for account" do
    lambda {
      category = JobPositionCategory.new
      category.account_id = @account.id
      category.name = 'foo'
      category.save!

      JobPositionCategory.all.size.should == 1
      result = JobPositionCategory.first
      result.name.should == 'foo'
      result.account_id.should == @account.id
    }.call
  end

  it "should update category successfully" do
    before_category = JobPositionCategory.create!(:name => 'foo', :account_id => @account.id)
    JobPositionCategory.find(before_category.id).update_attributes(:name => 'foo2').should == true
  end

end
