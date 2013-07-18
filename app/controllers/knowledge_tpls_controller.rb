class KnowledgeTplsController < ApplicationController

  before_filter :get_context
  before_filter :get_bread_crumb, :only => [:index, :show, :new, :edit]
  before_filter :auth, :except => [:get_account_knowledge_tpl]
  before_filter :auth_case_as_student, :only => [:get_account_knowledge_tpl]
  before_filter :context_is_root_account_filter, :except => [:get_account_knowledge_tpl]

  def get_account_knowledge_tpl
    @case_tpl = CaseTpl.find(params[:id])
    @case_issue = Knowledge.new
    @is_ajax = true
    render :layout => false
  end

  # GET /knowledges
  # GET /knowledges.xml
  def index
    @knowledge_tpls = CaseTpl.is_knowledge.find_all_by_context_id_and_context_type(params[:context_id], params[:context_type], :order => 'updated_at DESC')

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /knowledges/1
  # GET /knowledges/1.xml
  def show
    @knowledge_tpl = CaseTpl.find(params[:id])
    add_crumb @knowledge_tpl.name
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /knowledges/new
  # GET /knowledges/new.xml
  def new
    @knowledge_tpl = CaseTpl.init_knowledge_tpl

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /knowledges/1/edit
  def edit
    @knowledge_tpl = CaseTpl.find(params[:id])
  end

  # POST /knowledges
  # POST /knowledges.xml
  def create
    @knowledge_tpl = CaseTpl.new(params[:case_tpl])

    params[:case_tpl_widget].each { |widget|@knowledge_tpl.case_tpl_widgets.build(widget) }

    respond_to do |format|
      if @knowledge_tpl.save
        format.html { redirect_to(account_knowledge_tpls_url, :notice => t('#knowledge_tpls.save_successfully', 'Knowledge Template was successfully saved.')) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /knowledges/1
  # PUT /knowledges/1.xml
  def update
    result = false
    @knowledge_tpl = CaseTpl.find(params[:id])
    CaseTpl.transaction do
      @knowledge_tpl.case_tpl_widgets.destroy_all unless @knowledge_tpl.case_tpl_widgets.empty?
      params[:case_tpl_widget].each {|w| @knowledge_tpl.case_tpl_widgets.build(w)} unless params[:case_tpl_widget].nil?
      result = @knowledge_tpl.update_attributes(params[:case_tpl])
    end
    respond_to do |format|
      if result        
        format.html { redirect_to(account_knowledge_tpls_url, :notice => t('#knowledge_tpls.save_successfully', 'Knowledge Template was successfully saved.')) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /knowledges/1
  # DELETE /knowledges/1.xml
  def destroy
    @knowledge_tpl = CaseTpl.find(params[:id])
    @knowledge_tpl.remove

    respond_to do |format|
      format.html { redirect_to(account_knowledge_tpls_url) }
      format.xml  { head :ok }
    end
  end

  private

  def auth
    authorized_action(@context, @current_user, :manage_account_settings)
  end

  def get_bread_crumb
    add_crumb(t('#knowledge_tpls.bread_crumb.knowledge_tpl', 'Knowledge Templates'), account_knowledge_tpls_path(@context))
  end

end
