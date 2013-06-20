require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe CourseSystem do
  context "named scope" do
    before :each do
      course_model
      @account = Account.default
    end

    it "should get course_systems by with_rank" do
      course_system_model :rank => "mandatory"
      CourseSystem.with_rank('mandatory').should == [@course_system]
    end

    it "should get course_systems by of_account" do
      course_system_model
      CourseSystem.of_account(@account).should == [@course_system]
    end

    it "should get course_systems by of_job_position" do
      job_position_model
      course_system_model
      CourseSystem.of_job_position(@job_position).should == [@course_system]
    end

    it "should get course_systems by of_course_category" do
      @course_category = CourseCategory.create! :name => 'cc1'
      course_model :course_category => @course_category
      course_system_model
      CourseSystem.of_course_category(@course_category).should == [@course_system]
    end

    it "should group courses by rank" do
      job_position_with_user
      course_system_model :rank => 'mandatory', :account => @account
      course1= @course
      course_system_model :rank => 'optional', :account => @account
      course2= @course
      course_system_model :rank => 'recommended', :account => @account
      course3= @course
      courses = CourseSystem.group_courses_by_rank CourseSystem.all
      courses.should == {
        'mandatory' => [course1],
        'optional' => [course2],
        'recommended' => [course3],
      }
    end

    context "of_user_account" do
      it "should get course_systems with root_account and job position" do
        job_position_with_user
        course_system_model
        CourseSystem.of_user_account(@user, @account).should == [@course_system]
      end

      it "should get course_systems with root_account and no job position" do
        user_model
        job_position_model
        @user.user_account_associations.create! :account_id => @account.id
        course_system_model :job_position => nil
        CourseSystem.of_user_account(@user, @account).should == [@course_system]
      end

      it "should get course_systems with root_account and mixed job position" do
        user_model
        # no job position
        cs1 = course_system_model

        # with job position
        job_position_with_user :user => @user
        cs2 = course_system_model

        CourseSystem.of_user_account(@user, @account).sort_by(&:id).should == [cs1, cs2]
      end

      it "should not get course_systems that not in account position pair" do
        user_model

        # root account with no job position
        root_account = @account
        @user.user_account_associations.create! :account_id => root_account.id
        cs1 = course_system_model :account => root_account
        CourseSystem.of_user_account(@user, root_account).should == [cs1]

        # sub account with job position
        sub_account = account_model :parent_account => root_account
        job_position_with_user :user => @user, :account => sub_account
        cs2 = course_system_model :account => sub_account
        CourseSystem.of_user_account(@user, sub_account).sort_by(&:id).should == [cs1, cs2]

        # another user
        # another user with new job position
        # new user has nothing to do with cs2' job_position
        job_position_with_user :account => sub_account
        cs3 = course_system_model :account => sub_account
        CourseSystem.of_user_account(@user, sub_account).sort_by(&:id).should == [cs1, cs3]
      end
    end
  end
end

describe CourseSystemArray do
  before :each do
    course_model
    @account = Account.default
  end

  it "should act as array" do
    cs1 = @account.course_systems.create! :course => @course, :rank => 'mandatory'
    cs2 = @account.course_systems.create! :course => @course, :rank => 'optional'

    a = CourseSystemArray.new [cs1 ,cs2]
    a.should == [cs1, cs2]
  end

  it "should uniq" do
    cs1 = @account.course_systems.create! :course => @course, :rank => 'mandatory'
    cs2 = @account.course_systems.create! :course => @course, :rank => 'optional'

    a = CourseSystemArray.new [cs1 ,cs2]
    a.uniq.should == [cs1]
  end

  it "should uniq!" do
    cs1 = @account.course_systems.create! :course => @course, :rank => 'mandatory'
    cs2 = @account.course_systems.create! :course => @course, :rank => 'optional'

    a = CourseSystemArray.new [cs1 ,cs2]
    a.uniq!.should == [cs1]
    a.should == [cs1]
  end
end
