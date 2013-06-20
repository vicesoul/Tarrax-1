require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CourseSystemsController do
  before :each do
    account_model
  end

  context "GET 'index'" do
    it "should force login" do
      get 'index', :account_id => @account.id
      response.should be_redirect
    end

    it "should require authorization" do
      course_with_student_logged_in(:active_all => true, :account => @account)
      get 'index', :account_id => @account.id
      assert_unauthorized
    end

    it "should pass authorization with account admin" do
      course_with_student_logged_in(:active_all => true, :account => @account)
      account_admin_user :user => @user, :account => @account
      get 'index', :account_id => @account.id
      response.should be_success
    end
  end

  context "PUT 'bunch_update'" do
    it "should require authorization" do
      course_with_student_logged_in(:active_all => true, :account => @account)
      put 'bunch_update', :account_id => @account.id
      assert_unauthorized
    end

    it "should pass authorization with account admin" do
      course_with_student_logged_in(:active_all => true, :account => @account)
      account_admin_user :user => @user, :account => @account
      put 'bunch_update', :account_id => @account.id, :course_system_attributes => {:account_id => @account.id}
      response.should be_redirect
      response.location.should match ('/accounts/[0-9]*/course_systems') # redirect to index
    end
  end
end
