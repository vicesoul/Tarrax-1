class CaseIssuesController < ApplicationController

  before_filter :get_context

  # GET /case_issues
  # GET /case_issues.xml
  def index
    conditions = ['1=1']
    @case_issues = CaseIssue.find_all_by_case_repostory_id(Course.find(params[:context_id]).case_repostory.id, :conditions => conditions)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @case_issues }
    end
  end

  # GET /case_issues/1
  # GET /case_issues/1.xml
  def show
    @case_issue = CaseIssue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @case_issue }
    end
  end

  # GET /case_issues/new
  # GET /case_issues/new.xml
  def new
    @case_issue = Course.find(params[:context_id]).root_account.case_tpls.empty? ? CaseIssue.find_or_init_case_tpl : CaseIssue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @case_issue }
    end
  end

  # GET /case_issues/1/edit
  def edit
    @case_issue = CaseIssue.find(params[:id])
  end

  # POST /case_issues
  # POST /case_issues.xml
  def create
    @case_issue = CaseIssue.new(params[:case_issue])

    tpl = @case_issue.build_case_tpl(:name => 'Default case issue template', :user_id => @current_user.id)
    params[:case_tpl_widget].each { |widget| tpl.case_tpl_widgets.build(widget) }
    respond_to do |format|
      if @case_issue.save
        format.html { redirect_to(course_case_issues_url, :notice => 'CaseIssue was successfully created.') }
        format.xml  { render :xml => @case_issue, :status => :created, :location => course_case_issues_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @case_issue.errors, :status => :unprocessable_entity }
      end
    end
  end

  def submit_case_issue
    issue = CaseIssue.find(params[:id])
    render :json => issue.submit.to_json
  end

  def review_case_issue
    issue = CaseIssue.find(params[:id])
    issue.state == :awaiting_review and issue.review
    if (issue.state == :being_reviewed) && %w[accept reject].include?(params[:review_result])
      render :json => issue.__send__(params[:review_result]).to_json
    else
      render :json => false
    end
  end

  def apply_case_issue
    issue = CaseIssue.find(params[:id])
    if issue.state == :accepted  
      solution = CaseSolution.new(
        :case_issue => issue,
        :user => @current_user
      )
      result = solution.save
      if result
        issue.group_discuss == 'yes' ? solution.group_discuss : solution.execute
      end
      render :json => result.to_json
    else
      render :json => false.to_json
    end  
  end

  # PUT /case_issues/1
  # PUT /case_issues/1.xml
  def update
    result = false
    @case_issue = CaseIssue.find(params[:id])
    CaseIssue.transaction do 
      @case_issue.case_tpl.case_tpl_widgets.destroy_all unless @case_issue.case_tpl.case_tpl_widgets.empty?
      params[:case_tpl_widget].each {|w| @case_issue.case_tpl.case_tpl_widgets.build(w)} unless params[:case_tpl_widget].nil?
      result = @case_issue.update_attributes(params[:case_issue]) && @case_issue.case_tpl.save
    end

    respond_to do |format|
      if result   
        format.html { redirect_to(course_case_issues_url, :notice => 'CaseIssue was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @case_issue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /case_issues/1
  # DELETE /case_issues/1.xml
  #def destroy
    #@case_issue = CaseIssue.find(params[:id])
    #@case_issue.destroy

    #respond_to do |format|
      #format.html { redirect_to(case_issues_url) }
      #format.xml  { head :ok }
    #end
  #end
end
