class CaseSolutionsController < ApplicationController

  before_filter :get_context, :set_active_tab
  before_filter :get_bread_crumb, :only => [:index, :show, :edit]
  before_filter :auth_case_as_student, :except => [:review_case_solution]
  before_filter :auth_case_as_teacher, :only => [:review_case_solution]
  before_filter(:only => [:edit, :update, :destroy]) do |c|
    c.__send__(:auth_case_as_self) do 
      @case_solution = CaseSolution.find(c.params[:id])
      c.instance_variable_set(:@case_solution, @case_solution)
      c.__send__(:redirect_to, c.__send__(:course_case_issue_case_solutions_path)) unless @case_solution.user.id == c.instance_variable_get(:@current_user).id
    end
  end

  # GET /case_solutions
  # GET /case_solutions.xml
  def index
    @case_solutions = CaseSolution.find_all_by_case_issue_id(params[:case_issue_id])
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @case_solutions }
    end
  end

  # GET /case_solutions/1
  # GET /case_solutions/1.xml
  def show
    @case_solution = CaseSolution.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @case_solution }
    end
  end

  # GET /case_solutions/new
  # GET /case_solutions/new.xml
  #def new
    #@case_solution = CaseSolution.new

    #respond_to do |format|
      #format.html # new.html.erb
      #format.xml  { render :xml => @case_solution }
    #end
  #end

  # GET /case_solutions/1/edit
  def edit
    if @case_solution.executing?
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @case_solution }
      end
    else
      redirect_to :back
    end
  end

  def submit_case_solution
    case_solution = CaseSolution.find(params[:case_solution_id])
    if case_solution.user.id == @current_user.id
      render :json => case_solution.submit.to_json
    else
      render :json => false
    end
  end

  def review_case_solution
    case_solution = CaseSolution.find(params[:case_solution_id])
    if case_solution.being_reviewed? && %w[review recommend].include?(params[:review_result])
      render :json => case_solution.__send__(params[:review_result]).to_json
    else
      render :json => false
    end
  end

  # POST /case_solutions
  # POST /case_solutions.xml
  #def create
    #@case_solution = CaseSolution.new(params[:case_solution])

    #respond_to do |format|
      #if @case_solution.save
        #format.html { redirect_to(@case_solution, :notice => 'CaseSolution was successfully created.') }
        #format.xml  { render :xml => @case_solution, :status => :created, :location => @case_solution }
      #else
        #format.html { render :action => "new" }
        #format.xml  { render :xml => @case_solution.errors, :status => :unprocessable_entity }
      #end
    #end
  #end

  # PUT /case_solutions/1
  # PUT /case_solutions/1.xml
  def update
    #CaseSolution.transaction do
      #@case_solution.case_tpl.case_tpl_widgets.destroy_all if @case_solution.case_tpl && @case_solution.case_tpl.case_tpl_widgets.present?
      #case_tpl = @case_solution.case_tpl ? @case_solution.case_tpl : @case_solution.build_case_tpl(:name => 'Default case issue template', :user_id => @current_user.id)

      #params[:case_tpl_widget].each do |w|
        #case_tpl.case_tpl_widgets.build(w)
      #end unless params[:case_tpl_widget].nil?
      #result = @case_solution.update_attributes(params[:case_solution]) && case_tpl.save

    #end
    respond_to do |format|
      if @case_solution.update_attributes(params[:case_solution])
        format.html { redirect_to(course_case_issue_case_solution_url(@context, params[:case_issue_id]), :notice => 'CaseSolution was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @case_solution.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /case_solutions/1
  # DELETE /case_solutions/1.xml
  def destroy
    @case_solution.destroy if @case_solution.executing?

    respond_to do |format|
      format.html { redirect_to(course_case_issue_case_solutions_url) }
      format.xml  { head :ok }
    end
  end

  private

  def set_active_tab
    @active_tab = "case_repostory"
  end

  def get_bread_crumb
    add_crumb(t('', 'Case Issues'), course_case_issues_path(@context))
    add_crumb(t('', 'Case Solutions'), course_case_issue_case_solutions_path(@context, params[:case_issue_id])) if params[:case_issue_id]
  end

end
