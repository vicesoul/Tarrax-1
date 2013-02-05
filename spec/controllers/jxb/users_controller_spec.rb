require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe UsersController do

  context 'account admin creating users' do

    it "should create a pre_registered user (with special account)" do
      account  = Account.create!
      account1 = Account.create!
      account.sub_accounts << account1
      user_with_pseudonym(:account => account)
      account.add_user(@user)
      user_session(@user, @pseudonym)
      post 'create', :format => 'json', :account_id => account.id, :pseudonym => { :unique_id => 'jacob@instructure.com', :sis_user_id => 'testsisid' }, :user => { :name => 'Jacob Fugal', :account_id => account1.id }
      response.should be_success
      p = Pseudonym.find_by_unique_id('jacob@instructure.com')
      p.account_id.should == account.id
      account1.all_users.should include(p.user)
      p.should be_active
      p.sis_user_id.should == 'testsisid'
      p.user.should be_pre_registered
    end
  end

end
