class CourseColumnsController < ApplicationController
  before_filter :require_user
  before_filter :get_context

  include Api::V1::Json

  def index
    return unless authorized_action(@context, @current_user, :read)
    @course_columns = @context.course_columns

    respond_to do |format|
      format.json { render :json => api_json(@course_columns, @current_user, session) }
    end
  end

  def create
    return unless authorized_action(@context, @current_user, :update)
    @course_column = @context.course_columns.new column_params

    respond_to do |format|
      if @course_column.save
        format.json { render :json => api_json(@course_column, @current_user, session) }
      else
        format.json { render :json => @course_column.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    return unless authorized_action(@context, @current_user, :update)
    @course_column = CourseColumn.find params[:id]

    respond_to do |format|
      if @course_column.update_attributes column_params
        format.json { render :json => api_json(@course_column, @current_user, session) }
      else
        format.json { render :json => @course_column.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    return unless authorized_action(@context, @current_user, :update)
    @course_column = CourseColumn.find params[:id]
    @course_column.destroy

    respond_to do |format|
      format.json { render :json => api_json(@course_column, @current_user, session) }
    end
  end

  private
  def column_params
    params[:course_column].slice :slug, :name, :content, :position
  end
end
