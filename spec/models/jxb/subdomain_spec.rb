require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe Subdomain do
  #it "id should started from 10000" do
  #  domain = Subdomain.new(:name => 'abc001')
  #  domain.account_id = 1
  #  domain.save!
  #  domain.id.should >= 10000
  #end

  it "should create subdomain string based on id" do
    domain = Subdomain.new
    domain.account_id = 1
    domain.save!
    domain.name.should == "edu#{domain.id}"
  end

  it "should use given subdomain string if given" do
    domain = Subdomain.new(:name => 'abc001')
    domain.account_id = 1
    domain.save!
    domain.name.should == "abc001"
  end

  it "should auto create subdomain string" do
    a = Account.create
    a.subdomain.to_s.should =~ /edu[0-9]+/
  end

  it "should be deleted when associated account destroyed" do
    a = Account.create

    a.destroy!
    a.subdomain.destroyed?.should == true
  end
end
