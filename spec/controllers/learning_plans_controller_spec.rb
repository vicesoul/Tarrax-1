require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LearningPlansController do
  before :each do
    account_model
    course_with_student :active_all => true, :account => @account
  end

  def user_as_manager_role
    @role = @account.roles.create! :name => 'Learning plan manager' do |r|
      r.base_role_type = 'AccountMembership'
      r.workflow_state = 'active'
    end
    RoleOverride.manage_role_override @account, @role.name, 'manage_learning_plans', :override => true, :lock => false
    @user.flag_as_admin @account, @role.name
  end

  def manager_logged_in
    user_as_manager_role
    user_session @user
  end

  context "GET 'index'" do
    it "should force login" do
      get 'index', :account_id => @account.id
      response.should be_redirect
    end

    it "should require authorization" do
      user_session @user
      get 'index', :account_id => @account.id
      assert_unauthorized
    end

    it "should pass authorization with account admin" do
      manager_logged_in
      get 'index', :account_id => @account.id
      response.should be_success
    end
  end

  context "POST 'create'" do
    it "should require authorization" do
      user_session @user
      post 'create', :account_id => @account.id, :learning_plan => {:user_ids => '', :course_ids => ''}
      assert_unauthorized
    end

    it "should pass authorization with account admin" do
      manager_logged_in
      post 'create', :account_id => @account.id, :learning_plan_users_attributes => {}, :learning_plan_courses_attributes => {}
      response.should be_redirect
      response.location.should match ('/accounts/[0-9]*/learning_plans') # redirect to index
    end
  end

  context "PUT 'update'" do
    it "should require authorization" do
      user_session @user
      @learning_plan = @account.learning_plans.create! :subject => 'some...'
      put 'update', :account_id => @account.id, :id => @learning_plan.id
      assert_unauthorized
    end

    it "should pass authorization with account admin" do
      manager_logged_in
      @learning_plan = @account.learning_plans.create! :subject => 'some...'
      put 'update', :account_id => @account.id, :id => @learning_plan.id
      response.should be_redirect
      response.location.should match ('/accounts/[0-9]*/learning_plans') # redirect to index
    end
  end

  context "DELETE 'destroy'" do
    it "should require authorization" do
      user_session @user
      @learning_plan = @account.learning_plans.create! :subject => 'some...'
      delete 'destroy', :account_id => @account.id, :id => @learning_plan.id
      assert_unauthorized
    end

    it "should pass authorization with account admin" do
      manager_logged_in
      @learning_plan = @account.learning_plans.create! :subject => 'some...'
      delete 'destroy', :account_id => @account.id, :id => @learning_plan.id
      response.should be_success
    end
  end

  context "PUT 'publish'" do
    it "should require authorization" do
      user_session @user
      @learning_plan = @account.learning_plans.create! :subject => 'some...'
      put 'publish', :account_id => @account.id, :id => @learning_plan.id
      assert_unauthorized
    end

    it "should pass authorization with account admin" do
      manager_logged_in
      @learning_plan = @account.learning_plans.create! :subject => 'some...'
      put 'publish', :account_id => @account.id, :id => @learning_plan.id
      response.should be_success
    end
  end

  context "PUT 'revert'" do
    it "should require authorization" do
      user_session @user
      @learning_plan = @account.learning_plans.create! :subject => 'some...'
      @learning_plan.publish!
      put 'revert', :account_id => @account.id, :id => @learning_plan.id
      assert_unauthorized
    end

    it "should pass authorization with account admin" do
      manager_logged_in
      @learning_plan = @account.learning_plans.create! :subject => 'some...'
      @learning_plan.publish!
      put 'revert', :account_id => @account.id, :id => @learning_plan.id
      response.should be_success
    end
  end
end
