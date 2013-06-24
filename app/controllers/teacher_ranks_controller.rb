class TeacherRanksController < ApplicationController
  before_filter :get_context

  add_crumb(proc{t('#teacher_ranks.teacher_ranks_management', 'Teacher Ranks')}, :account_teacher_ranks_path)
  @show_left_side = true

  # GET /teacher_ranks
  # GET /teacher_ranks.xml
  def index
    @teacher_ranks = @context.teacher_ranks.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teacher_ranks }
    end
  end

  # GET /teacher_ranks/1
  # GET /teacher_ranks/1.xml
  def show
    @teacher_rank = @context.teacher_ranks.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teacher_rank }
    end
  end

  # GET /teacher_ranks/new
  # GET /teacher_ranks/new.xml
  def new
    @teacher_rank = @context.teacher_ranks.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @teacher_rank }
    end
  end

  # GET /teacher_ranks/1/edit
  def edit
    @teacher_rank = @context.teacher_ranks.find(params[:id])
  end

  # POST /teacher_ranks
  # POST /teacher_ranks.xml
  def create
    @teacher_rank = @context.teacher_ranks.build(params[:teacher_rank])

    respond_to do |format|
      if @teacher_rank.save
        format.html { redirect_to([@context, @teacher_rank], :notice => t('created_successfully', 'TeacherRank was successfully created.')) }
        format.xml  { render :xml => @teacher_rank, :status => :created, :location => [@context, @teacher_rank] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @teacher_rank.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /teacher_ranks/1
  # PUT /teacher_ranks/1.xml
  def update
    @teacher_rank = @context.teacher_ranks.find(params[:id])

    respond_to do |format|
      if @teacher_rank.update_attributes(params[:teacher_rank])
        format.html { redirect_to([@context, @teacher_rank], :notice => t('updated_successfully', 'TeacherRank was successfully updated.')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @teacher_rank.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teacher_ranks/1
  # DELETE /teacher_ranks/1.xml
  def destroy
    @teacher_rank = @context.teacher_ranks.find(params[:id])
    @teacher_rank.destroy

    respond_to do |format|
      format.html { redirect_to(teacher_ranks_url) }
      format.xml  { head :ok }
    end
  end
end
