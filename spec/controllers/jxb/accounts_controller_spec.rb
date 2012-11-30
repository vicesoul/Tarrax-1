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
end
