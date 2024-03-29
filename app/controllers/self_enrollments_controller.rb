#
# Copyright (C) 2012 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

class SelfEnrollmentsController < ApplicationController
  before_filter :infer_signup_info, :only => [:new, :create]
  before_filter :require_user, :only => :create

  include Api::V1::Course

  def new
    if !@current_user && delegated_authentication_url?
      store_location
      flash[:notice] = t('notices.login_required', "Please log in to join this course.")
      return redirect_to login_url
    end
  end

  def create
    @current_user.validation_root_account = @domain_root_account
    @current_user.require_self_enrollment_code = true
    @current_user.self_enrollment_code = params[:self_enrollment_code]
    if @current_user.save
      self_enrollment_course = @current_user.self_enrollment_course
      Jxb::Widget.update_courses_while_course_was_added(@current_user.dashboard_page.id, self_enrollment_course.id) unless @current_user.dashboard_page.blank?
      render :json => course_json(self_enrollment_course, @current_user, session, [], nil)
    else
      course_id = Course.find_by_self_enrollment_code(params[:self_enrollment_code]).id
      render :json => {:user => @current_user.errors.as_json[:errors], :course_id => course_id}, :status => :bad_request
    end
  end

  private

  def infer_signup_info
    @embeddable = true
    #@course = @domain_root_account.self_enrollment_course_for(params[:self_enrollment_code])
    @course = Course.find_by_self_enrollment_code(params[:self_enrollment_code])

    # TODO: have a join code field in new.html.erb if none is provided in the url
    raise ActiveRecord::RecordNotFound unless @course
  end
end
