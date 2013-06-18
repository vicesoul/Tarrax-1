require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe User do 

  before :each do 
    @user = user_model
    @user_account_association = tie_user_to_user_account_association(@user) 
    @job_position = @user_account_association.job_position
  end

  context "validations" do
    it "should pass with nil birthday when saving user" do
      @user.birthday = nil
      @user.save.should == true
    end

    it "should rasie error while using incorrect birthday" do
      lambda {
        @user.birthday = "198a-11-11"
        @user.save!
      }.should raise_error
    end

    it "should successfully to create a user with correct birthday" do
      @user.birthday = "1990-11-11"
      @user.save.should == true
    end

    it "should pass with nil mobile phone when saving user" do
      @user.mobile_phone = nil
      @user.save.should == true
    end

    it "should rasie error while using incorrect mobile phone" do
      lambda {
        @user.birthday = "132323"
        @user.save!
      }.should raise_error
    end

    it "should successfully to create a user with correct mobile phone" do
        @user.mobile_phone = "13564754220"
        @user.save.should == true
    end

    context "advanced query users at account" do

      it "should query users with job number" do
        User.search(:user_account_associations_job_number_equals => @user_account_association.job_number).first.id.should == @user.id
      end

      it "should query users with job position" do 
        User.search(:user_account_associations_job_position_id_in => [@job_position.id]).first.id.should == @user.id
      end

      it "should query users with accounts" do
        User.search(:user_account_associations_account_id_in => [Account.default.id]).first.id.should == @user.id
      end

      it "should query users with name" do 
        User.search(:name_like => @user.name.upcase).first.id.should == @user.id
      end

      it "should query users with external" do
        User.search(:user_account_associations_external_equals => 'false').first.id.should == @user.id
      end

      it "should query users with tags" do
        User.search(:user_account_associations_taggable_with_tags => @user_account_association.tag_list).first.id.should == @user.id
      end

    end

   end
end
