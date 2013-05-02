class Jxb::PagesController < ApplicationController
  before_filter :get_context

  # GET /jxb_pages
  # GET /jxb_pages.xml
  def index
    @jxb_pages = Jxb::Page.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jxb_pages }
    end
  end

  # GET /jxb_pages/1
  # GET /jxb_pages/1.xml
  def show
    @page = Jxb::Page.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /jxb_pages/new
  # GET /jxb_pages/new.xml
  def new
    @page = Jxb::Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /jxb_pages/1/edit
  def edit
    @page = Jxb::Page.find(params[:id])
  end

  # POST /jxb_pages
  # POST /jxb_pages.xml
  def create
    @page = Jxb::Page.new(params[:page])

    respond_to do |format|
      if @page.save
        format.html { redirect_to(@page, :notice => 'Jxb::Page was successfully created.') }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    if authorized_action(@account, @current_user, nil, :manage_homepage)
      @page = Jxb::Page.find(params[:id])
      if @page.update_attributes(params[:jxb_page]) and @page.name == 'homepage'
        redirect_to account_homepage_path(@account), :notice => 'Homepage was successfully updated.'
      end
    end
  end

  def update_theme
    if authorized_action(@account, @current_user, nil, :manage_homepage)
      page = Jxb::Page.find_by_context_id_and_context_type(params[:account_id], params[:context_type])
      page.theme = params[:theme]
      respond_to do |format|
        if page.save
          format.json {render :json => {:flag => true}.to_json}
        else
          format.json {render :json => {:flag => false}.to_json}
        end
      end
    end
  end

  # DELETE /jxb_pages/1
  # DELETE /jxb_pages/1.xml
  def destroy
    @page = Jxb::Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to(jxb_pages_url) }
      format.xml  { head :ok }
    end
  end

end
