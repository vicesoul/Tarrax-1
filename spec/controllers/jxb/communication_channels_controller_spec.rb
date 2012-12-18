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

describe CommunicationChannelsController do
  let(:default_account) { LoadAccount.default_domain_root_account }

  describe "GET 'confirm'" do
    describe "open registration" do
      it "should register creation_pending user in the correct account" do
        @account = Account.create!
        course(:active_all => 1, :account => @account)
        user
        @user.update_attribute(:workflow_state, 'creation_pending')
        @cc = @user.communication_channels.create!(:path => 'jt@instructure.com')
        @enrollment = @course.enroll_student(@user)
        @user.should be_creation_pending
        @enrollment.should be_invited
        get 'confirm', :nonce => @cc.confirmation_code
        response.should be_success
        assigns[:pseudonym].should be_new_record
        assigns[:pseudonym].unique_id.should == 'jt@instructure.com'
        # should create pseudonym under default account
        #assigns[:pseudonym].account.should == @account
        #assigns[:root_account].should == @account
        assigns[:pseudonym].account.should == default_account
        assigns[:root_account].should == default_account

        post 'confirm', :nonce => @cc.confirmation_code, :register => 1, :pseudonym => {:password => 'asdfasdf', :password_confirmation => 'asdfasdf'}
        response.should be_redirect
        @user.reload
        @user.should be_registered
        @enrollment.reload
        @enrollment.should be_invited
        @cc.reload
        @cc.should be_active
        @user.pseudonyms.length.should == 1
        @pseudonym = @user.pseudonyms.first
        @pseudonym.should be_active
        @pseudonym.unique_id.should == 'jt@instructure.com'
        @pseudonym.account.should == default_account
        # communication_channel is redefed to do a lookup
        @pseudonym.communication_channel_id.should == @cc.id
      end

      it "should register creation_pending user in the correct account (admin)" do
        @account = Account.create!
        user
        @user.update_attribute(:workflow_state, 'creation_pending')
        @account.add_user(@user)
        @cc = @user.communication_channels.create!(:path => 'jt@instructure.com')
        @user.should be_creation_pending
        get 'confirm', :nonce => @cc.confirmation_code
        response.should be_success
        assigns[:pseudonym].should be_new_record
        assigns[:pseudonym].unique_id.should == 'jt@instructure.com'
        # should create pseudonym under default account
        #assigns[:pseudonym].account.should == @account
        #assigns[:root_account].should == @account
        assigns[:pseudonym].account.should == default_account
        assigns[:root_account].should == default_account

        post 'confirm', :nonce => @cc.confirmation_code, :register => 1, :pseudonym => {:password => 'asdfasdf', :password_confirmation => 'asdfasdf'}
        response.should be_redirect
        @user.reload
        @user.should be_registered
        @cc.reload
        @cc.should be_active
        @user.pseudonyms.length.should == 1
        @pseudonym = @user.pseudonyms.first
        @pseudonym.should be_active
        @pseudonym.unique_id.should == 'jt@instructure.com'
        @pseudonym.account.should == default_account
        # communication_channel is redefed to do a lookup
        @pseudonym.communication_channel_id.should == @cc.id
      end
      it "should not forget the account when registering for a non-default account" do
        # should create pseudonym under default account
        #@account = Account.create!
        @account = Account.default
        @course = Course.create!(:account => @account) { |c| c.workflow_state = 'available' }
        user_with_pseudonym(:account => @account, :password => :autogenerate)
        @enrollment = @course.enroll_user(@user)
        @pseudonym.account.should == @account
        @user.should be_pre_registered

        post 'confirm', :nonce => @cc.confirmation_code, :enrollment => @enrollment.uuid, :register => 1, :pseudonym => {:password => 'asdfasdf', :password_confirmation => 'asdfasdf'}
        response.should be_redirect
        @user.reload
        @user.should be_registered
        @pseudonym.reload
        @pseudonym.account.should == @account
      end

      it "should figure out the correct domain when registering" do
        # should create pseudonym under default account
        #@account = Account.create!
        @account = Account.default
        user_with_pseudonym(:account => @account, :password => :autogenerate)
        @pseudonym.account.should == @account
        @user.should be_pre_registered

        # @domain_root_account == Account.default
        post 'confirm', :nonce => @cc.confirmation_code
        response.should be_success
        response.should render_template('confirm')
        assigns[:pseudonym].should == @pseudonym
        assigns[:root_account].should == @account
      end
    end
  end
end
