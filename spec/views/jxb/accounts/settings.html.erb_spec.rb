require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../views_helper')

describe "accounts/settings.html.erb" do
  
  describe "managed by site admins" do
    before do
      @account = Account.default
      assigns[:account] = @account
      assigns[:account_users] = []
      assigns[:root_account] = @account
      assigns[:associated_courses_count] = 0
      assigns[:announcements] = []
    end

    it "should not show account_settings_enable_scheduler in site admins" do
      admin = site_admin_user
      view_context(@account, admin)
      render
      response.should_not have_tag("input#account_settings_enable_scheduler")
    end

  end

end
