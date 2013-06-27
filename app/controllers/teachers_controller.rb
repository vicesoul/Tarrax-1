class TeachersController < ApplicationController
  before_filter :require_user
  before_filter :get_context

  layout :layout_method

  add_crumb(proc{t('#teachers.teachers_management', 'Teachers')}, :account_teachers_path)
  @show_left_side = true

  def layout_method
    params[:is_iframe] ? 'bare' : 'application'
  end

  # GET /teachers
  # GET /teachers.xml
  def index
    @teachers = @context.teachers.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teachers }
    end
  end

  # GET /teachers/1
  # GET /teachers/1.xml
  def show
    @teacher = @context.teachers.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teacher }
    end
  end

  # GET /teachers/new
  # GET /teachers/new.xml
  def new
    @teacher = @context.teachers.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @teacher }
    end
  end

  # GET /teachers/1/edit
  def edit
    @teacher = @context.teachers.find(params[:id])
  end

  # POST /teachers
  # POST /teachers.xml
  def create
    @teacher = @context.teachers.new(params[:teacher])

    respond_to do |format|
      if @teacher.save
        format.html { redirect_to([@context, @teacher ], :notice => t('created_successfully', 'Teacher was successfully created.')) }
        format.xml  { render :xml => @teacher, :status => :created, :location => [@context, @teacher ] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @teacher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /teachers/1
  # PUT /teachers/1.xml
  def update
    @teacher = @context.teachers.find(params[:id])

    respond_to do |format|
      if @teacher.update_attributes(params[:teacher])
        format.html { redirect_to([@context, @teacher ], :notice => t('updated_successfully', 'Teacher was successfully updated.')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @teacher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teachers/1
  # DELETE /teachers/1.xml
  def destroy
    @teacher = @context.teachers.find(params[:id])
    @teacher.destroy

    respond_to do |format|
      format.html { redirect_to(account_teachers_url) }
      format.xml  { head :ok }
    end
  end

  private
    def iframe_request?
      params[:is_iframe]
    end
    helper_method :'iframe_request?'
end
