class KnowledgesController < ApplicationController

  before_filter :get_context, :set_active_tab
  before_filter :get_bread_crumb, :only => [:index, :show, :new, :edit]
  before_filter :auth_knowledge_as_student, :except => [:review_knowledge]
  before_filter :auth_knowledge_as_teacher, :only => [:review_knowledge]
  # GET /knowledges
  # GET /knowledges.xml
  def index
    case_repostory_id = Course.find(params[:context_id]).knowledge_repostory.id
    search_params =
      if params[:search].nil?
        {:case_repostory_id_equals => case_repostory_id}
      else
        params[:search].merge!(:case_repostory_id_equals => case_repostory_id)
      end
    search_params.merge!(:search_as_student => @current_user.id) if validate_knowledge_as_student && (!validate_knowledge_as_teacher) 
    @search = Knowledge.search(search_params)
    @knowledges = @search.paginate(:page => params[:page], :per_page => 25, :total_entries => @search.size)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @knowledges }
    end
  end

  # GET /knowledges/1
  # GET /knowledges/1.xml
  def show
    @knowledge = Knowledge.find(params[:id])

    return render(:layout => 'bare') if params[:is_iframe]
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @knowledge }
    end
  end

  # GET /knowledges/new
  # GET /knowledges/new.xml
  def new
    return (redirect_to course_knowledges_path) unless auth_as_account_settings
    @knowledge = Knowledge.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @knowledge }
    end
  end

  # GET /knowledges/1/edit
  def edit
    @knowledge = Knowledge.find(params[:id])
  end

  # POST /knowledges
  # POST /knowledges.xml
  def create
    return (redirect_to course_knowledges_path) unless auth_as_account_settings
    @knowledge = Knowledge.new(params[:knowledge])
    if params[:case_tpl_widget].blank?
      flash[:error] = 'Please select a knowledge template'
      render :action => :new
    else
      tpl = @knowledge.build_case_tpl(:name => 'Default knowledge template', :user_id => @current_user.id)
      params[:case_tpl_widget].each { |widget| tpl.case_tpl_widgets.build(widget) }
      respond_to do |format|
        if @knowledge.save
          @knowledge.direct_accept if validate_knowledge_as_teacher
          format.html { redirect_to(course_knowledges_url, :notice => 'Knowledge was successfully created.') }
          format.xml  { render :xml => @knowledge, :status => :created, :location => @knowledge }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @knowledge.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /knowledges/1
  # PUT /knowledges/1.xml
  def update
    result = false
    @knowledge = Knowledge.find(params[:id])
    Knowledge.transaction do 
      @knowledge.case_tpl.case_tpl_widgets.destroy_all unless @knowledge.case_tpl.case_tpl_widgets.empty?
      params[:case_tpl_widget].each {|w| @knowledge.case_tpl.case_tpl_widgets.build(w)} unless params[:case_tpl_widget].nil?
      result = @knowledge.update_attributes(params[:knowledge]) && @knowledge.case_tpl.save
    end

    respond_to do |format|
      if result   
        format.html { redirect_to(course_knowledges_url, :notice => 'Knowledge was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @knowledge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /knowledges/1
  # DELETE /knowledges/1.xml
  def destroy
    @knowledge = Knowledge.find(params[:id])
    @knowledge.destroy

    respond_to do |format|
      format.html { redirect_to(course_knowledges_url(@context)) }
      format.xml  { head :ok }
    end
  end

  def submit_knowledge
    knowledge = Knowledge.find(params[:knowledge_id])
    if knowledge.user.id == @current_user.id
      render :json => knowledge.submit.to_json
    else
      render :json => false
    end
  end

  def review_knowledge
    knowledge = Knowledge.find(params[:knowledge_id])
    if knowledge.awaiting_review? && %w[accept reject].include?(params[:review_result])
      knowledge.review
      render :json => knowledge.__send__(params[:review_result]).to_json
    else
      render :json => false
    end
  end

  private

  def set_active_tab
    @active_tab = "knowledge"
  end

  def get_bread_crumb
    add_crumb(t('#knowledges.bread_crumb.knowledge', 'Knowledges'), course_knowledges_path(@context))
  end

  def auth_as_account_settings
    @context.root_account.settings[:student_can_commit_knowledge] || validate_knowledge_as_teacher
  end

  def validate_knowledge_as_student
    @context.grants_right?(@current_user, :operate_knowledge_as_student)
  end

  def validate_knowledge_as_teacher
    @context.grants_right?(@current_user, :operate_knowledge_as_teacher)
  end

end
