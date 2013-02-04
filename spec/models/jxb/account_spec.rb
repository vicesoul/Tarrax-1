require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe Account do
  context "subdomain" do
    let!(:domain) {
      Account.default.create_subdomain(:name => 'edu123')
    }

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

  context "multi accounts" do
    it "should failed to create a root account with existed name" do
      Account.create!(:name => 'abc')
      expect {
        Account.create!(:name => 'abc')
      }.to raise_error( ActiveRecord::RecordInvalid, 'Validation failed: Name has already been taken' )
    end

    it "should successfully create a account with existed name in different scope" do
      root = Account.create!(:name => 'abc')
      expect {
        Account.create!(:name => 'abc', :parent_account => root)
      }.to_not raise_error( ActiveRecord::RecordInvalid, 'Validation failed: Name has already been taken' )
    end

    it "should failed to create a sub account with existed name" do
      root = Account.create!(:name => 'abc')
      Account.create!(:name => 'abc', :parent_account => root)
      expect {
        Account.create!(:name => 'abc', :parent_account => root)
      }.to raise_error( ActiveRecord::RecordInvalid, 'Validation failed: Name has already been taken' )
    end
  end
end
