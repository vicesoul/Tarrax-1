class CaseSolutionsController < ApplicationController

  before_filter :get_context

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
    @case_solution = CaseSolution.find(params[:id])
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
    @case_solution = CaseSolution.find(params[:id])
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
        format.html { redirect_to(@case_solution, :notice => 'CaseSolution was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @case_solution.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /case_solutions/1
  # DELETE /case_solutions/1.xml
  #def destroy
    #@case_solution = CaseSolution.find(params[:id])
    #@case_solution.destroy

    #respond_to do |format|
      #format.html { redirect_to(case_solutions_url) }
      #format.xml  { head :ok }
    #end
  #end
end
