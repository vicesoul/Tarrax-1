class CaseTplsController < ApplicationController

  before_filter :get_context
  before_filter :get_bread_crumb, :only => [:index, :show, :new, :edit]
  before_filter :auth, :except => [:get_account_case_tpl]
  before_filter :auth_case_as_student, :only => [:get_account_case_tpl]
  before_filter :context_is_root_account_filter, :except => [:get_account_case_tpl]

  def get_account_case_tpl
   @case_tpl = CaseTpl.find(params[:id])
   render :layout => false
  end

  # GET /case_tpls
  # GET /case_tpls.xml
  def index
    @case_tpls = CaseTpl.find_all_by_context_id_and_context_type(params[:context_id], params[:context_type], :order => 'updated_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @case_tpls }
    end
  end

  # GET /case_tpls/1
  # GET /case_tpls/1.xml
  def show
    @case_tpl = CaseTpl.find(params[:id])
    add_crumb @case_tpl.name
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @case_tpl }
    end
  end

  # GET /case_tpls/new
  # GET /case_tpls/new.xml
  def new
    @case_tpl = CaseTpl.init_case_tpl

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @case_tpl }
    end
  end

  # GET /case_tpls/1/edit
  def edit
    @case_tpl = CaseTpl.find(params[:id])
    add_crumb @case_tpl.name
  end

  # POST /case_tpls
  # POST /case_tpls.xml
  def create
    @case_tpl = CaseTpl.new(params[:case_tpl])

    params[:case_tpl_widget].each { |widget|@case_tpl.case_tpl_widgets.build(widget) }

    respond_to do |format|
      if @case_tpl.save
        format.html { redirect_to(account_case_tpls_url, :notice => t('#case_tpls.save_successfully', 'CaseTpl was successfully created.')) }
        format.xml  { render :xml => account_case_tpls_url, :status => :created, :location => account_case_tpls_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @case_tpl.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /case_tpls/1
  # PUT /case_tpls/1.xml
  def update
    result = false
    @case_tpl = CaseTpl.find(params[:id])
    CaseTpl.transaction do
      @case_tpl.case_tpl_widgets.destroy_all unless @case_tpl.case_tpl_widgets.empty?
      params[:case_tpl_widget].each {|w| @case_tpl.case_tpl_widgets.build(w)} unless params[:case_tpl_widget].nil?
      result = @case_tpl.update_attributes(params[:case_tpl])
    end
    respond_to do |format|
      if result        
        format.html { redirect_to(account_case_tpls_url, :notice => t('save_successfully', 'CaseTpl was successfully updated.')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @case_tpl.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /case_tpls/1
  # DELETE /case_tpls/1.xml
  def destroy
    @case_tpl = CaseTpl.find(params[:id])
    @case_tpl.destroy

    respond_to do |format|
      format.html { redirect_to(account_case_tpls_url) }
      format.xml  { head :ok }
    end
  end

  private

  def auth
    authorized_action(@context, @current_user, :manage_account_settings)
  end

  def get_bread_crumb
    add_crumb(t('#case_tpls.bread_crumb.case_tpl', 'Case Templates'), account_case_tpls_path(@context))
  end

end
