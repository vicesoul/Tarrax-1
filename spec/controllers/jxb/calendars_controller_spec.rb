require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe CalendarsController do
  def course_event(date=nil)
    date = Date.parse(date) if date
    @event = @course.calendar_events.create(:title => "some assignment", :start_at => date, :end_at => date)
  end

  def calendar2_only!
    Account.default.update_attribute :settings, {
      :enable_scheduler => true,
      :calendar2_only => true
    }
  end

  def calendar1_only!
    Account.default.update_attribute :settings, {
      :enable_scheduler => false,
      :calendar2_only => false
    }
  end

  describe "GET 'show'" do

    it "should assign variables" do
      calendar1_only!
      course_with_student_logged_in(:active_all => true)
      course_event
      get 'show', :user_id => @user.id
      response.should be_success
      assigns[:contexts].should_not be_nil
      assigns[:contexts].should_not be_empty
      assigns[:contexts][0].should eql(@user)
      assigns[:contexts][1].should eql(@course)
      assigns[:events].should_not be_nil
      assigns[:undated_events].should_not be_nil
    end

    it "should retrieve multiple contexts for user" do
      calendar1_only!
      course_with_student_logged_in(:active_all => true)
      course_event
      e = @user.calendar_events.create(:title => "my event")
      get 'show', :user_id => @user.id, :include_undated => true
      response.should be_success
      assigns[:contexts].should_not be_nil
      assigns[:contexts].should_not be_empty
      assigns[:contexts].length.should eql(2)
      assigns[:contexts][0].should eql(@user)
      assigns[:contexts][1].should eql(@course)
    end

    it "should retrieve events for a given month and year" do
      calendar1_only!
      course_with_student_logged_in(:active_all => true)
      e1 = course_event("Jan 1 2008")
      e2 = course_event("Feb 15 2008")
      get 'show', :month => "01", :year => "2008" #, :course_id => @course.id, :month => "01", :year => "2008"
      response.should be_success

      get 'show', :month => "02", :year => "2008"
      response.should be_success
    end

  end

  describe "GET 'show2'" do
    it "should redirect if the user should be on the old calendar" do
      calendar1_only!
      course_with_student_logged_in(:active_all => true)
      get 'show2', :user_id => @user.id
      response.should be_redirect
      response.redirected_to.should == {:action => 'show', :anchor => ' '}
    end
  end

  describe "POST 'switch_calendar'" do
    it "should never switch to the old calendar" do
      Account.default.update_attribute(:settings, {:enable_scheduler => true})
      course_with_student_logged_in(:active_all => true)
      @user.preferences[:use_calendar1].should be_nil

      post 'switch_calendar', {:preferred_calendar => '1'}
      response.should be_redirect
      response.redirected_to.should == {:action => 'show2', :anchor => ' '}
      @user.reload.preferences[:use_calendar1].should be_true
    end

    it "should always switch to the new calendar if allowed or not" do
      course_with_student_logged_in(:active_all => true)
      @user.preferences[:use_calendar1].should be_nil

      post 'switch_calendar', {:preferred_calendar => '2'}
      response.should be_redirect
      response.redirected_to.should == {:action => 'show2', :anchor => ' '}
      @user.reload.preferences[:use_calendar1].should be_nil
    end

  end
end
