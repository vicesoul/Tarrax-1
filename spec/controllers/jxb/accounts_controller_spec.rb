require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe AccountsController do
  def account_with_admin_logged_in(opts = {})
    @account = Account.default
    account_admin_user
    user_session(@admin)
  end

  def cross_listed_course
    account_with_admin_logged_in
    @account1 = Account.create!
    @account1.add_user(@user)
    @course1 = @course
    @course1.account = @account1
    @course1.save!
    @account2 = Account.create!
    @course2 = course
    @course2.account = @account2
    @course2.save!
    @course2.course_sections.first.crosslist_to_course(@course1)
  end

  describe "update" do

    it "should not allow non-site-admins to update certain settings" do
      account_with_admin_logged_in
      post 'update', :id => @account.id, :account => { :settings => { 
        :global_includes => true, :enable_scheduler => false, :enable_profiles => true } }
      @account.reload
      @account.global_includes?.should be_false
      @account.enable_scheduler?.should be_true
      @account.enable_profiles?.should be_false
    end

  end

  describe "homepage" do
    
    it "should return 401 if user do not belong to account" do
      rescue_action_in_public!
      account_model
      user_with_pseudonym(:active_all => true)
      user_session(@user, @pseudonym)
      get 'homepage', :account_id => @account.id
      assert_unauthorized
    end

    it "should not manage homepage if user have no right" do
      rescue_action_in_public!
      account_model
      user_with_pseudonym(:active_all => true)
      ua = UserAccountAssociation.new
      ua.account_id = @account.id
      ua.user_id = @user.id
      ua.save
      user_session(@user, @pseudonym)
      get 'homepage', :account_id => @account.id
      assigns(:can_manage_homepage).should == false
      assigns(:show_left_side).should == false
      response.should be_success
    end

    it "should use different theme" do
      account_with_admin_logged_in
      get 'homepage', :account_id => @account.id
      response.should render_template("accounts/homepage")
      controller.view_paths.first.to_s.should match(/themes\/jxb/)
    end

  end

end
