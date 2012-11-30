require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe Subdomain do
  #it "id should started from 10000" do
  #  domain = Subdomain.new(:subdomain => 'abc001')
  #  domain.account_id = 1
  #  domain.save!
  #  domain.id.should >= 10000
  #end

  it "should create subdomain string based on id" do
    domain = Subdomain.new
    domain.account_id = 1
    domain.save!
    domain.subdomain.should == "edu#{domain.id}"
  end

  it "should use given subdomain string if given" do
    domain = Subdomain.new(:subdomain => 'abc001')
    domain.account_id = 1
    domain.save!
    domain.subdomain.should == "abc001"
  end
end
