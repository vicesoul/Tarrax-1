class AccountNotificationCategoryController < ApplicationController

  before_filter :get_context

  def create
    if authorized_action(@account, @current_user, nil, :manage_account_notification_category)
      result = AccountNotificationCategory.create(
        :name => params[:account_notification_category][:name],
        :account_id => params[:account_notification_category][:account_id]
      )
      render :json => {:flag => !result.nil?, :categories => result }.to_json  
    end
  end

  def edit
  end

  def update
    if authorized_action(@account, @current_user, nil, :manage_account_notification_category)
      category = AccountNotificationCategory.find(params[:id])
      category.name = params[:account_notification_category][:name]
      result = category.save
      render :json => {:flag => result, :categories => category, :type => 'edit' }.to_json  
    end
  end

  def index
    if authorized_action(@account, @current_user, nil, :manage_account_notification_category)
      @show_left_side = true
      @categories = AccountNotificationCategory.find_all_by_account_id(params[:account_id])
    end
  end

  def show
  end

end
