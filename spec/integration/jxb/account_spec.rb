require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe AccountsController do
  context "subdomain" do
    before(:each) do
      @acct1 = Account.create!
      domain = Subdomain.new(:name => 'ed123')
      domain.account_id = @acct1.id
      domain.save!
      account_admin_user(:account => @acct1)
    end

    it "should switch to specific domain root account if subdomain given" do
      user_session(@admin)

      get 'http://ed123.lvh.me'
      response.header['X-Canvas-Domain-Root-Account-Id'].should == "#{@acct1.id}"
    end

    it "should switch to default domain root account" do
      user_session(@admin)

      get 'http://www.lvh.me'
      response.header['X-Canvas-Domain-Root-Account-Id'].should == "#{Account.default.id}"
    end

    it "should switch to default domain root account if subdomain not exists" do
      user_session(@admin)

      get 'http://no-such-subdomain.lvh.me'
      response.header['X-Canvas-Domain-Root-Account-Id'].should == "#{Account.default.id}"
    end
  end
end
