class UserCell < ApplicationCell
  cache :index, :expires_in => 5.minutes

  def index
    @users = @opts[:account].all_users(10)
    prepend_view_path Jxb::Theme.widget_path(@opts[:theme])

    render
  end

end
