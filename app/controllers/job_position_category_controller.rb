class JobPositionCategoryController < ApplicationController
  before_filter :get_context

  @show_left_side = true
  
  def new
    @category = JobPositionCategory.new
  end

  def create
    @category = JobPositionCategory.new(params[:job_position_category])
    respond_to do |format|
      if @category.save
        format.html {redirect_to account_job_position_categories_url, :notice => 'Job position category was created successfully' }
      else
        format.html {render :action => 'new'}
      end
    end
  end

  def edit
    @category = JobPositionCategory.find(params[:id])
  end

  def update
    @category = JobPositionCategory.find(params[:id])
    respond_to do |format|
      if @category.update_attributes(params[:job_position_category])
        format.html {redirect_to account_job_position_categories_url, :notice => 'Job position category was updated successfully' }
      end
    end
  end


  def index
    @categories = JobPositionCategory.find_all_by_account_id(params[:account_id])
  end

end
