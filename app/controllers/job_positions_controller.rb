class JobPositionsController < ApplicationController
  # GET /job_positions
  # GET /job_positions.xml
  def index
    @job_positions = JobPosition.find_all_by_account_id(params[:account_id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @job_positions }
    end
  end

  # GET /job_positions/1
  # GET /job_positions/1.xml
  #def show
    #@job_position = JobPosition.find(params[:id])

    #respond_to do |format|
      #format.html # show.html.erb
      #format.xml  { render :xml => @job_position }
    #end
  #end

  # GET /job_positions/new
  # GET /job_positions/new.xml
  def new
    @job_position = JobPosition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job_position }
    end
  end

  # GET /job_positions/1/edit
  def edit
    @job_position = JobPosition.find(params[:id])
  end

  # POST /job_positions
  # POST /job_positions.xml
  def create
    @job_position = JobPosition.new(params[:job_position])

    respond_to do |format|
      if @job_position.save
        format.html { redirect_to(account_job_positions_path, :notice => 'JobPosition was successfully created.') }
        format.xml  { render :xml => @job_position, :status => :created, :location => @job_position }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job_position.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /job_positions/1
  # PUT /job_positions/1.xml
  def update
    @job_position = JobPosition.find(params[:id])

    respond_to do |format|
      if @job_position.update_attributes(params[:job_position])
        format.html { redirect_to(account_job_positions_path, :notice => 'JobPosition was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job_position.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /job_positions/1
  # DELETE /job_positions/1.xml
  #def destroy
    #@job_position = JobPosition.find(params[:id])
    #@job_position.destroy

    #respond_to do |format|
      #format.html { redirect_to(job_positions_url) }
      #format.xml  { head :ok }
    #end
  #end
end
