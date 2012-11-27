require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe Account do
  context "subdomain" do
    let!(:domain) { Subdomain.create!(:account => Account.default, :subdomain => 'ed123') }

    it 'should return subdomain related with root account' do
      acct = Account.default
      acct.subdomain.should == domain
    end

    it "should return root account's subdomain for sub account" do
      acct = Account.default
      sub1 = acct.manually_created_courses_account
      sub1.subdomain.should == domain
    end
  end
end
