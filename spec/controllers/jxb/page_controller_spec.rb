require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Jxb::PagesController do
  
  context "update" do 
    
    before :each do
      rescue_action_in_public!
      account_model
      @homepage = @account.create_homepage(:name => 'homepage')

      user_with_pseudonym(:active_all => true)
      user_session(@user, @pseudonym)
    end

    it "should return 401 if user do not have right to manage page" do
      put 'update', :account_id => @account.id, :id => @homepage.id
      assert_unauthorized
    end

    it "should redirect to account homepage with notice if page name is homepage" do
      @account.add_user(@user)
      put 'update', :account_id => @account.id, :id => @homepage.id, :jxb_page => { 'theme' => 'foo'}

      @homepage.reload.theme.should == 'foo'
      response.should redirect_to "/accounts/#{@account.id}/homepage"
    end

  end

end
