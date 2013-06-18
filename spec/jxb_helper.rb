module JxbHelper
  def job_position_with_user(opts={})
    @user = opts[:user] || user_model
    @job_position = opts[:job_position] || job_position_model
    account = opts[:account] || @account || account_model
    @user.user_account_associations.create! :account_id => account.id, :job_position => @job_position
  end
end
