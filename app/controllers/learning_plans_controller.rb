class LearningPlansController < ApplicationController
  before_filter :require_user
  before_filter :get_context

  def index
    return unless authorized_action(@account, @current_user, :read)

    @learning_plans = LearningPlan.active.of_account(@account).paginate(:page => params[:page], :per_page => 10)
  end

  def search_courses
    return unless authorized_action(@account, @current_user, :read)

    @course_systems = CourseSystem.of_account(search_params[:account_ids])
    @course_systems = @course_systems.of_job_position(search_params[:job_position_ids]) unless search_params[:job_position_ids].blank?
    @course_systems = @course_systems.of_course_category(search_params[:course_category_ids]) unless search_params[:course_category_ids].blank?

    @rest_courses = Course.of_account search_params[:account_ids]
    @rest_courses = @rest_courses.of_course_category(search_params[:course_category_ids]) unless search_params[:course_category_ids].blank?
    @rest_courses = @rest_courses - @course_systems.map(&:course)

    render :partial => "course_selection"
  end

  def new
    @learning_plan = LearningPlan.new
  end

  def create
    return unless authorized_action(@account, @current_user, :manage_learning_plans)

    @learning_plan = @account.learning_plans.build(params[:learning_plan])

    respond_to do |format|
      if @learning_plan.save
        flash[:notice] = t('created_successfully', "Learning plan created successfully.")
        format.html { redirect_to account_learning_plans_path }
      else
        format.html { render :action => :new }
      end
    end
  end

  def show
    flash.keep
    redirect_to :action => :edit
  end

  def edit
    @learning_plan = @account.learning_plans.find params[:id]
    return unless authorized_action(@learning_plan, @current_user, :read)
  end

  def update
    @learning_plan = LearningPlan.find params[:id]
    return unless authorized_action(@learning_plan, @current_user, :update)

    respond_to do |format|
      if @learning_plan.update_attributes params[:learning_plan]
        flash[:notice] = t('notices.update_success', "Update successfully")
        format.html { redirect_to [@account, @learning_plan] }
      else
        flash[:error] = t('errors.update_failed', "Update failed")
        format.html { redirect_to [@account, @learning_plan] }
      end
    end
  end

  def publish
    @learning_plan = LearningPlan.find params[:id]
    if authorized_action(@learning_plan, @current_user, :publish)
      @learning_plan.publish!
      respond_to do |format|
        format.html { render :partial => 'learning_plan', :object => @learning_plan }
      end
    end
  end

  def revert
    @learning_plan = LearningPlan.find params[:id]
    if authorized_action(@learning_plan, @current_user, :revert)
      @learning_plan.revert!
      respond_to do |format|
        format.html { render :partial => 'learning_plan', :object => @learning_plan }
      end
    end
  end

  def destroy
    @learning_plan = LearningPlan.find params[:id]
    if authorized_action(@learning_plan, @current_user, :delete)
      @learning_plan.destroy
      respond_to do |format|
        format.json { render :json => @learning_plan.to_json }
        format.html { redirect_to :back } # back to current page
      end
    end
  end

  private
    def search_params
      @search_params ||= prepare_params :search
    end

    def prepare_params name
      return if params[name].nil?

      parse_params = params[name].dup
      parse_params.reject! {|k,v| v.blank? }
      parse_params.each do |k,v|
        parse_params[k].reject! {|i| i.blank? } if k.end_with? '_ids'
      end
      parse_params
    end
end
