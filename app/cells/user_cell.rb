class UserCell < ApplicationCell
  cache :index, :expires_in => 5.minutes

  def index
    @users = account.all_users(10)
    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end
