require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe Subdomain do
  #it "id should started from 10000" do
  #  domain = Subdomain.create!(:account_id => 1, :subdomain => 'abc001')
  #  domain.id.should >= 10000
  #end

  it "should create subdomain string based on id" do
    domain = Subdomain.create!(:account_id => 1)
    domain.subdomain.should == "edu#{domain.id}"
  end

  it "should use given subdomain string if given" do
    domain = Subdomain.create!(:account_id => 1, :subdomain => 'abc001')
    domain.subdomain.should == "abc001"
  end
end
