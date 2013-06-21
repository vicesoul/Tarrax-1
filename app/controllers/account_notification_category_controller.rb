class AccountNotificationCategoryController < ApplicationController

  before_filter :get_context
  before_filter :auth

  def create
    result = AccountNotificationCategory.create(
      :name => params[:account_notification_category][:name],
      :account_id => params[:account_notification_category][:account_id]
    )
    render :json => {:flag => !result.nil?, :categories => result }.to_json
  end

  def edit
  end

  def update
    category = AccountNotificationCategory.find(params[:id])
    category.name = params[:account_notification_category][:name]
    result = category.save
    render :json => {:flag => result, :categories => category, :type => 'edit' }.to_json
  end

  def index
    @show_left_side = true
    @categories = AccountNotificationCategory.find_all_by_account_id(params[:account_id])
  end


  private

  def auth
    authorized_action(@context, @current_user, :manage_account_notification_category)
  end
end
