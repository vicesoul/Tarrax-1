#
# Copyright (C) 2012 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsController do

  context "SAML meta data" do
    before(:each) do
      Setting.set_config('saml', {
              :tech_contact_name => nil,
              :tech_contact_email => nil
      })
      @account = Account.create!(:name => "test")
    end

    it 'should render for non SAML configured accounts' do
      get "/saml_meta_data"
      response.should be_success
      response.body.should_not == ""
    end
    
    it "should use the correct entity_id" do
      HostUrl.stubs(:default_host).returns('bob.cody.instructure.com')
      @aac = @account.account_authorization_configs.create!(:auth_type => "saml")
      
      get "/saml_meta_data"
      response.should be_success
      doc = Nokogiri::XML(response.body)
      doc.at_css("EntityDescriptor")['entityID'].should == "http://bob.cody.instructure.com/saml2"
    end

  end

  context "subdomain" do
    before(:each) do
      @acct1 = Account.create!
      Subdomain.create!(:account => @acct1, :subdomain => 'ed123')
      account_admin_user(:account => @acct1)
    end

    it "should switch to specific domain root account if subdomain given" do
      user_session(@admin)

      get 'http://ed123.lvh.me'
      response.header['X-Canvas-Domain-Root-Account-Id'].should == "#{@acct1.id}"
    end

    it "should switch to default domain root account" do
      user_session(@admin)

      get 'http://www.lvh.me'
      response.header['X-Canvas-Domain-Root-Account-Id'].should == "#{Account.default.id}"
    end

    it "should switch to default domain root account if subdomain not exists" do
      user_session(@admin)

      get 'http://no-such-subdomain.lvh.me'
      response.header['X-Canvas-Domain-Root-Account-Id'].should == "#{Account.default.id}"
    end
  end
end
