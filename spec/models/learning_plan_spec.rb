require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe LearningPlan do
  before :each do
    @learning_plan = account_model.learning_plans.create :subject => 'new learning plan', :start_on => Date.current, :end_on => 1.month.from_now
  end

  context "role type" do
    it "should create plan with base_role_type" do
      @learning_plan.enrollment_type_for_name('StudentEnrollment').should == {:type => 'StudentEnrollment'}
    end

    it "should create plan with custom role type" do
      @account.roles.create! :name => 'custom role' do |r|
        r.base_role_type = 'TeacherEnrollment'
      end
      @learning_plan.enrollment_type_for_name('custom role').should == {:type => 'TeacherEnrollment', :name => 'custom role'}
    end

    it "should cache enrollment_type results" do
      @account.roles.create! :name => 'custom role' do |r|
        r.base_role_type = 'TeacherEnrollment'
      end
      @learning_plan.enrollment_type_for_name('StudentEnrollment').should == {:type => "StudentEnrollment"}
      @learning_plan.enrollment_type_for_name('custom role').should == {:type => 'TeacherEnrollment', :name => 'custom role'}
      @learning_plan.enrollment_type_for_name('StudentEnrollment').should == {:type => "StudentEnrollment"}
      @learning_plan.enrollment_type_for_name('custom role').should == {:type => 'TeacherEnrollment', :name => 'custom role'}
    end

    it "should raise error if role not exists" do
      expect {
        @learning_plan.enrollment_type_for_name('custom role')
      }.to raise_error
    end

  end

  context "workflow" do
    it "should be initial" do
      @learning_plan.workflow_state.should == 'initial'
    end

    it "should be published" do
      @learning_plan.publish!
      @learning_plan.workflow_state.should == 'published'
    end

    it "should be reverted" do
      @learning_plan.publish!
      @learning_plan.revert!
      @learning_plan.workflow_state.should == 'reverted'
    end

    it "should be published after revert" do
      @learning_plan.publish!
      @learning_plan.revert!
      @learning_plan.publish!
      @learning_plan.workflow_state.should == 'published'
    end
  end

  it "should publish plan" do
    @learning_plan.learning_plan_users_attributes = {"0" => {:user_id => user_model.id, :role_name => 'StudentEnrollment' }}
    @learning_plan.courses << course_model
    @learning_plan.save!

    @learning_plan.workflow_state.should == 'initial'
    @learning_plan.publish!

    @learning_plan.workflow_state.should == 'published'
    @learning_plan.enrollments.active.size.should == 1
  end

  it "should skip enroll if enrollment exists" do
    course_with_student

    @learning_plan.learning_plan_users_attributes = {"0" => {:user_id => @user.id, :role_name => 'StudentEnrollment' }}
    @learning_plan.courses << @course
    @learning_plan.save!

    @learning_plan.workflow_state.should == 'initial'
    @learning_plan.publish!

    @learning_plan.workflow_state.should == 'published'
    @learning_plan.enrollments.active.size.should == 0
    @learning_plan.learning_plan_users.first.workflow_state.should == 'initial'
  end

  it "should partial enroll if partial enrollments exists" do
    course_with_student

    @learning_plan.learning_plan_users_attributes = {"0" => {:user_id => @user.id, :role_name => 'StudentEnrollment' }}
    @learning_plan.courses << @course
    @learning_plan.courses << course_model
    @learning_plan.save!

    @learning_plan.workflow_state.should == 'initial'
    @learning_plan.publish!

    @learning_plan.workflow_state.should == 'published'
    @learning_plan.enrollments.active.size.should == 1
    @learning_plan.learning_plan_users.first.workflow_state.should == 'partial'
  end

  it "should publish plan with multiple users and courses" do
    @learning_plan.learning_plan_users_attributes = {
      "0" => {:user_id => user_model.id, :role_name => 'StudentEnrollment' },
      "1" => {:user_id => user_model.id, :role_name => 'TeacherEnrollment' },
    }
    @learning_plan.courses << course_model
    @learning_plan.courses << course_model
    @learning_plan.save!

    @learning_plan.workflow_state.should == 'initial'
    @learning_plan.publish!

    @learning_plan.workflow_state.should == 'published'
    @learning_plan.enrollments.active.size.should == 4
  end

  it "should publish plan with multiple users and courses for custom role" do
    @account.roles.create! :name => 'custom role' do |r|
      r.base_role_type = 'TeacherEnrollment'
    end

    @learning_plan.learning_plan_users_attributes = {
      "0" => {:user_id => user_model.id, :role_name => 'StudentEnrollment' },
      "1" => {:user_id => user_model.id, :role_name => 'custom role' },
    }
    @learning_plan.courses << course_model
    @learning_plan.courses << course_model
    @learning_plan.save!

    @learning_plan.workflow_state.should == 'initial'
    @learning_plan.publish!

    @learning_plan.workflow_state.should == 'published'
    @learning_plan.enrollments.active.size.should == 4
  end

  it "should revert plan" do
    @learning_plan.learning_plan_users_attributes = {"0" => {:user_id => user_model.id, :role_name => 'StudentEnrollment' }}
    @learning_plan.courses << course_model
    @learning_plan.save!
    @learning_plan.publish!

    @learning_plan.workflow_state.should == 'published'
    @learning_plan.revert!
    @learning_plan.enrollments.size.should == 1
    @learning_plan.enrollments.active.size.should == 0
    @learning_plan.workflow_state.should == 'reverted'
  end

  it "should revert plan with multiple users and courses" do
    @learning_plan.learning_plan_users_attributes = {
      "0" => {:user_id => user_model.id, :role_name => 'StudentEnrollment' },
      "1" => {:user_id => user_model.id, :role_name => 'TeacherEnrollment' },
    }
    @learning_plan.courses << course_model
    @learning_plan.courses << course_model
    @learning_plan.save!

    @learning_plan.workflow_state.should == 'initial'
    @learning_plan.publish!

    @learning_plan.workflow_state.should == 'published'
    @learning_plan.enrollments.size.should == 4

    @learning_plan.revert!
    @learning_plan.enrollments.size.should == 4
    @learning_plan.enrollments.active.size.should == 0
    @learning_plan.workflow_state.should == 'reverted'
  end

  it "should revert plan with multiple users and courses for custom role" do
    @account.roles.create! :name => 'custom role' do |r|
      r.base_role_type = 'TeacherEnrollment'
    end

    @learning_plan.learning_plan_users_attributes = {
      "0" => {:user_id => user_model.id, :role_name => 'StudentEnrollment' },
      "1" => {:user_id => user_model.id, :role_name => 'custom role' },
    }
    @learning_plan.courses << course_model
    @learning_plan.courses << course_model
    @learning_plan.save!

    @learning_plan.workflow_state.should == 'initial'
    @learning_plan.publish!

    @learning_plan.workflow_state.should == 'published'
    @learning_plan.enrollments.active.size.should == 4

    @learning_plan.revert!
    @learning_plan.enrollments.size.should == 4
    @learning_plan.enrollments.active.size.should == 0
    @learning_plan.workflow_state.should == 'reverted'
  end

  it "should revert partial enrollments" do
    course_with_student

    @learning_plan.learning_plan_users_attributes = {"0" => {:user_id => @user.id, :role_name => 'StudentEnrollment' }}
    @learning_plan.courses << @course
    @learning_plan.courses << course_model
    @learning_plan.save!

    @learning_plan.workflow_state.should == 'initial'
    @learning_plan.publish!

    @learning_plan.workflow_state.should == 'published'
    @learning_plan.enrollments.active.size.should == 1
    @learning_plan.learning_plan_users.first.workflow_state.should == 'partial'

    @learning_plan.revert!
    @learning_plan.enrollments.active.size.should == 0
    @learning_plan.learning_plan_users.first.workflow_state.should == 'reverted'
    @user.enrollments.active.size.should == 1
  end

  context "section" do
    it "should get section name from account list" do
      a1 = account_model :name => 'a1'
      a2 = account_model :name => 'a2'
      a3 = account_model :name => 'a3'
      accounts = [a1, a2, a3]
      user = user_model
      user.stubs(:user_account_associations).returns( stub(:find_all_by_account_id => [stub(:account_id => a1.id), stub(:account_id => a2.id), stub(:account_id => a3.id)]) )
      section_name = @learning_plan.send :section_name_from_account_tree, user, accounts
      section_name.should == 'a3'
    end

    it "should create section if not exists" do
      course_with_student
      @learning_plan.learning_plan_users_attributes = {"0" => {:user_id => user_model.id, :role_name => 'StudentEnrollment' }}
      @learning_plan.courses << @course
      @learning_plan.save!

      @learning_plan.account.update_attributes! :name => 'jxb'
      UserAccountAssociation.create! :user_id => @user.id, :account_id => @learning_plan.account.id
      @learning_plan.section_mappings = [@learning_plan.account_id]

      @learning_plan.publish!

      @learning_plan.enrollments.first.course_section.name.should == 'jxb'
    end

    it "should not create new section if exists" do
      course_with_student
      @course.course_sections.create :name => 'jxb'
      @learning_plan.learning_plan_users_attributes = {"0" => {:user_id => user_model.id, :role_name => 'StudentEnrollment' }}
      @learning_plan.courses << @course
      @learning_plan.save!

      @learning_plan.account.update_attributes! :name => 'jxb'
      UserAccountAssociation.create! :user_id => @user.id, :account_id => @learning_plan.account.id
      @learning_plan.section_mappings = [@learning_plan.account_id]

      @learning_plan.publish!

      @course.course_sections.find_all_by_name('jxb').size.should == 1

      @learning_plan.enrollments.first.course_section.name.should == 'jxb'
    end

    it "should attend to more than 1 course" do
      course_with_student
      c1 = @course

      @learning_plan.learning_plan_users_attributes = {"0" => {:user_id => user_model.id, :role_name => 'StudentEnrollment' }}
      @learning_plan.courses << @course
      @learning_plan.courses << course_model
      @learning_plan.save!

      c2 = @course

      @learning_plan.publish!

      @learning_plan.enrollments.size.should == 2
      @learning_plan.enrollments.map(&:course).sort.should == [c1, c2]

      @learning_plan.enrollments.first.course_section.name.should == 'jxb'
      @learning_plan.enrollments.last.course_section.name.should == 'jxb'
    end
  end

  context "account tree" do
    before :each do
      account_model
      @root_account = @account

      account_model :parent_account => @root_account
      @account1 = @account
      account_model :parent_account => @account1
      @account11 = @account
      account_model :parent_account => @account1
      @account12 = @account

      account_model :parent_account => @root_account
      @account2 = @account
      account_model :parent_account => @account2
      @account21 = @account
      account_model :parent_account => @account2
      @account22 = @account

      @learning_plan = learning_plan_model :account => @root_account
    end

    it "should build account tree" do
      tree = @learning_plan.send :build_tree, @root_account, [@root_account, @account1, @account11, @account12]
      tree[:id].should == @root_account.id
      tree[:name].should == @root_account.name
      tree[:children][0][:id].should == @account1.id
      tree[:children][0][:name].should == @account1.name
      tree[:children][0][:children].should include(:id => @account11.id, :name => @account11.name, :children => [])
      tree[:children][0][:children].should include(:id => @account12.id, :name => @account12.name, :children => [])
    end

    it "should get account tree" do
      user_model
      @account11.attach_users [@user.id]
      @account12.attach_users [@user.id]
      @learning_plan.users << @user

      tree = @learning_plan.account_tree
      tree[:id].should == @root_account.id
      tree[:name].should == @root_account.name
      tree[:children][0][:id].should == @account1.id
      tree[:children][0][:name].should == @account1.name
      tree[:children][0][:children].should include(:id => @account11.id, :name => @account11.name, :children => [])
      tree[:children][0][:children].should include(:id => @account12.id, :name => @account12.name, :children => [])
    end
  end
end
