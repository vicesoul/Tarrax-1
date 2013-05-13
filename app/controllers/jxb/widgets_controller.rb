class Jxb::WidgetsController < ApplicationController
  before_filter :get_context

  # GET /jxb_widgets
  # GET /jxb_widgets.xml
  def index
    @jxb_widgets = Jxb::Widget.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jxb_widgets }
    end
  end

  # GET /jxb_widgets/1
  # GET /jxb_widgets/1.xml
  def show
    @widget = Jxb::Widget.find(params[:id])
    @page   = @widget.page
    clear_crumbs
    @show_left_side = false
    prepend_view_path Jxb::Theme.path(@page.theme)
    respond_to do |format|
      format.html
    end
  end

  # GET /jxb_widgets/new
  # GET /jxb_widgets/new.xml
  def new
    @page = Jxb::Page.find params[:page_id]
    render :layout => false
  end

  # GET /jxb_widgets/1/edit
  def edit
    @widget = Jxb::Widget.find(params[:id])
  end

  # POST /jxb_widgets
  # POST /jxb_widgets.xml
  def create
    @widget = Jxb::Widget.new(params[:widget])

    respond_to do |format|
      if @widget.save
        format.html { redirect_to(@widget, :notice => 'Jxb::Widget was successfully created.') }
        format.xml  { render :xml => @widget, :status => :created, :location => @widget }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @widget.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /jxb_widgets/1
  # PUT /jxb_widgets/1.xml
  def update
    @widget = Jxb::Widget.find(params[:id])

    respond_to do |format|
      params[:widget][:courses] = params[:widget][:courses].split(',')
      params[:widget][:courses] = params[:widget][:courses].blank? ? params[:widget][:courses].unshift('0') : params[:widget][:courses].map(&:to_i)
      if @widget.update_attributes(params[:widget])
        format.js { head :ok }
      else
        format.js { head :error }
      end
    end
  end

  # DELETE /jxb_widgets/1
  # DELETE /jxb_widgets/1.xml
  def destroy
    @widget = Jxb::Widget.find(params[:id])
    @widget.destroy

    respond_to do |format|
      format.html { redirect_to(jxb_widgets_url) }
      format.xml  { head :ok }
    end
  end
end
