require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe LearningPlan do
  before :each do
    @learning_plan = account_model.learning_plans.create :subject => 'new learning plan'
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

end
