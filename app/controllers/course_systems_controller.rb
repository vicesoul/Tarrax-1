class CourseSystemsController < ApplicationController
  before_filter :require_user
  before_filter :get_context

  def index
    return unless authorized_action(@account, @current_user, :read)

    if search_params
      @course_account = Account.find search_params[:account_id]
      scoped = CourseSystem.of_account(@course_account)
      scoped = scoped.of_job_position(search_params[:job_position_id]) unless search_params[:job_position_id].blank?
      scoped = scoped.of_course_category(search_params[:course_category_id]) unless search_params[:course_category_id].blank?
      @rest_courses = @course_account.courses
      @rest_courses = @rest_courses.of_course_category(search_params[:course_category_ids]) unless search_params[:course_category_ids].blank?
      @rest_courses = @rest_courses - scoped.map(&:course)
    else
      @course_account = @account
      scoped = CourseSystem.of_account(@course_account).of_job_position(nil)
      @rest_courses = @course_account.courses - scoped.map(&:course)
    end

    @grouped_courses = CourseSystem.group_courses_by_rank scoped
  end

  def bunch_update
    return unless authorized_action(@account, @current_user, :manage_course_systems)

    account = Account.find course_system_params[:account_id]
    job_position_id = course_system_params[:job_position_id]

    all_cs = account.course_systems.of_job_position job_position_id

    new_cs = []
    CourseSystem::RANKS.each do |rank|
      (course_system_params[rank] || []).each do |course_id|
        cs = account.course_systems.find_or_initialize_by_job_position_id_and_course_id(job_position_id, course_id)
        cs.update_attributes! :rank => rank
        new_cs << cs
      end
    end

    # delete cs
    (all_cs - new_cs).each &:destroy

    respond_to do |format|
      flash[:notice] = t('update_successfully', 'Course systems updated successfully.')
      format.html { redirect_to :action => :index, :search => course_system_params }
    end
  end

  def courses
    course_systems = @current_user.course_systems
  end

  private
    def course_system_params
      @course_system_params ||= prepare_params :course_system_attributes
    end

    def search_params
      @search_params ||= prepare_params :search
    end

    def prepare_params name
      return if params[name].nil?

      parse_params = params[name].dup
      parse_params.reject! {|k,v| v.blank? } # reject blank parameters
      parse_params.each do |k,v|
        parse_params[k].reject! {|i| i.blank? } if k.end_with? '_ids' # reject blank parameters in array
      end
      parse_params
    end
end
