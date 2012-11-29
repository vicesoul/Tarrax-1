require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe GradebooksController do

  describe "GET 'change_gradebook_version'" do
    it 'should always switch to gradebook2 if clicked and back to gradebook1 if clicked with reset=true' do
      course_with_teacher_logged_in(:active_all => true)
      get 'grade_summary', :course_id => @course.id

      response.should be_redirect
      response.should redirect_to(:controller => 'gradebook2', :action => 'show')

      # reset back to showing the old gradebook
      get 'change_gradebook_version', :course_id => @course.id, :version => 1
      response.should redirect_to(:controller => 'gradebook2', :action => 'show')

      # tell it to use gradebook 2
      get 'change_gradebook_version', :course_id => @course.id, :version => 2
      response.should redirect_to(:controller => 'gradebook2', :action => 'show')
    end
  end

 end
