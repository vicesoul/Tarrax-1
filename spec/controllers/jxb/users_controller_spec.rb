#
# Copyright (C) 2011 Instructure, Inc.
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

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe UsersController do
  let(:default_account) {LoadAccount.default_domain_root_account}

  context "POST 'create'" do
    context 'account admin creating users' do
      it "should create a pre_registered user (in the correct account)" do
        account = Account.create!
        user_with_pseudonym(:account => account)
        account.add_user(@user)
        user_session(@user, @pseudonym)
        post 'create', :format => 'json', :account_id => account.id, :pseudonym => { :unique_id => 'jacob@instructure.com', :sis_user_id => 'testsisid' }, :user => { :name => 'Jacob Fugal' }
        response.should be_success
        p = Pseudonym.find_by_unique_id('jacob@instructure.com')
        p.account_id.should == default_account.id
        p.should be_active
        p.sis_user_id.should == 'testsisid'
        p.user.should be_pre_registered
      end

      it "should not allow an admin to set the sis id when creating a user if they don't have privileges to manage sis" do
        account = Account.create!
        admin = account_admin_user_with_role_changes(:account => account, :role_changes => {'manage_sis' => false})
        user_session(admin)
        post 'create', :format => 'json', :account_id => account.id, :pseudonym => { :unique_id => 'jacob@instructure.com', :sis_user_id => 'testsisid' }, :user => { :name => 'Jacob Fugal' }
        response.should be_success
        p = Pseudonym.find_by_unique_id('jacob@instructure.com')
        # should create pseudonym under default account
        #p.account_id.should == account.id
        p.account_id.should == default_account.id
        p.should be_active
        p.sis_user_id.should be_nil
        p.user.should be_pre_registered
      end

      it "should association user with non-default account" do
        account = Account.create!
        admin = account_admin_user_with_role_changes(:account => account, :role_changes => {'manage_sis' => false})
        user_session(admin)
        post 'create', :format => 'json', :account_id => account.id, :pseudonym => { :unique_id => 'jacob@instructure.com', :sis_user_id => 'testsisid' }, :user => { :name => 'Jacob Fugal' }
        response.should be_success
        p = Pseudonym.find_by_unique_id('jacob@instructure.com')
        # should create pseudonym under default account
        #p.account_id.should == account.id
        p.account_id.should == default_account.id
        p.should be_active
        p.sis_user_id.should be_nil
        p.user.should be_pre_registered
      end
    end

    context 'user account associations' do
      it "should associate user with non-default account" do
        account = Account.create!
        user_with_pseudonym
        account.add_user(@user)
        user_session(@user, @pseudonym)
        post 'create', :format => 'json', :account_id => account.id, :pseudonym => { :unique_id => 'jacob@instructure.com', :sis_user_id => 'testsisid' }, :user => { :name => 'Jacob Fugal' }
        response.should be_success
        p = Pseudonym.find_by_unique_id('jacob@instructure.com')
        p.account_id.should == default_account.id
        p.should be_active
        p.sis_user_id.should == 'testsisid'
        p.user.should be_pre_registered
        @user.reload
        @user.associated_accounts.should include(account)
      end

      it "should associate user with non-default account and it's parent account" do
        root_account = Account.create!
        sub_account = Account.create(:parent_account => root_account)
        user_with_pseudonym
        root_account.add_user(@user)
        user_session(@user, @pseudonym)
        post 'create', :format => 'json', :account_id => sub_account.id, :pseudonym => { :unique_id => 'jacob@instructure.com', :sis_user_id => 'testsisid' }, :user => { :name => 'Jacob Fugal' }
        response.should be_success
        p = Pseudonym.find_by_unique_id('jacob@instructure.com')
        p.account_id.should == default_account.id
        p.should be_active
        p.sis_user_id.should == 'testsisid'
        p.user.should be_pre_registered
        p.user.associated_accounts.should include(sub_account)
        p.user.associated_accounts.should include(root_account)
      end

      it "should be failed if want to create a user in other account" do
        account = Account.create!
        user_with_pseudonym
        user_session(@user, @pseudonym)
        post 'create', :format => 'json', :account_id => account.id, :pseudonym => { :unique_id => 'jacob@instructure.com', :sis_user_id => 'testsisid' }, :user => { :name => 'Jacob Fugal' }
        response.should_not be_success
      end
    end
  end
end
