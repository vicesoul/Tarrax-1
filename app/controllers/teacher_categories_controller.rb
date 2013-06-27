class TeacherCategoriesController < ApplicationController
  before_filter :get_context

  add_crumb(proc{t('#teacher_categories.teacher_categories_management', 'Teacher Categories')}, :account_teacher_categories_path)
  @show_left_side = true

  # GET /teacher_categories
  # GET /teacher_categories.xml
  def index
    @teacher_categories = @context.teacher_categories.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teacher_categories }
    end
  end

  # GET /teacher_categories/1
  # GET /teacher_categories/1.xml
  def show
    @teacher_category = @context.teacher_categories.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teacher_category }
    end
  end

  # GET /teacher_categories/new
  # GET /teacher_categories/new.xml
  def new
    @teacher_category = @context.teacher_categories.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @teacher_category }
    end
  end

  # GET /teacher_categories/1/edit
  def edit
    @teacher_category = @context.teacher_categories.find(params[:id])
  end

  # POST /teacher_categories
  # POST /teacher_categories.xml
  def create
    @teacher_category = @context.teacher_categories.new(params[:teacher_category])

    respond_to do |format|
      if @teacher_category.save
        format.html { redirect_to([@context, @teacher_category], :notice => t("created_successfully", 'TeacherCategory was successfully created.')) }
        format.xml  { render :xml => @teacher_category, :status => :created, :location => @teacher_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @teacher_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /teacher_categories/1
  # PUT /teacher_categories/1.xml
  def update
    @teacher_category = @context.teacher_categories.find(params[:id])

    respond_to do |format|
      if @teacher_category.update_attributes(params[:teacher_category])
        format.html { redirect_to([@context, @teacher_category], :notice => t("updated_successfully", 'TeacherCategory was successfully updated.')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @teacher_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teacher_categories/1
  # DELETE /teacher_categories/1.xml
  def destroy
    @teacher_category = @context.teacher_categories.find(params[:id])
    @teacher_category.destroy

    respond_to do |format|
      format.html { redirect_to(account_teacher_categories_url) }
      format.xml  { head :ok }
    end
  end
end
