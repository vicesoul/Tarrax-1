require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper.rb')

def gen_ssha_password(password)
  salt = ActiveSupport::SecureRandom.random_bytes(10)
  "{SSHA}" + Base64.encode64(Digest::SHA1.digest(password+salt).unpack('H*').first+salt).gsub(/\s/, '')
end

describe SIS::CSV::UserImporter do

  before :each do 
    @foo_account = Account.default
  end

  
  it "should create new user with special account" do
    process_csv_data_cleanly(
      "user_id,login_id,status,first_name,last_name,email,password,ssha_password,account_id,enrollment_type",
      "user_1,user1,active,User,Uno,user@example.com,111111,,#{@foo_account.id},student"
    )
    user = CommunicationChannel.find_by_path('user@example.com').user
    @foo_account.all_users.should include(user)
  end

  it "should create new user with enrollment_type" do
    process_csv_data_cleanly(
      "user_id,login_id,status,first_name,last_name,email,password,ssha_password,account_id,enrollment_type",
      "user_1,user1,active,User,Uno,user@example.com,111111,,#{@foo_account.id},student"
    )
    user = CommunicationChannel.find_by_path('user@example.com').user
    associate = UserAccountAssociation.find(:first, :conditions => { :user_id => user.id, :account_id => @foo_account.id })
    associate.enrollment_type.should == "student"
  end

  it "should reuse login_id and email if user already inmport form sis" do
    process_csv_data_cleanly(
      "user_id,login_id,status,first_name,last_name,email,password,ssha_password,account_id,enrollment_type",
      "user_1,user1,active,User,Uno,user@example.com,111111,,#{@foo_account.id},student"
    )
    lambda { CommunicationChannel.create!(:path => 'user@example.com') }.should_not raise_error
  end

  it "should successful if move a user from one account to anothor" do

  end

end
