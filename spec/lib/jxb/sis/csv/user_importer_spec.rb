require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper.rb')

def gen_ssha_password(password)
  salt = ActiveSupport::SecureRandom.random_bytes(10)
  "{SSHA}" + Base64.encode64(Digest::SHA1.digest(password+salt).unpack('H*').first+salt).gsub(/\s/, '')
end

describe SIS::CSV::UserImporter do

  before { account_model }

  it "should create new user with special account" do
    foo_account = factory_with_protected_attributes(Account, {:name => "foo"})
    process_csv_data_cleanly(
      "user_id,login_id,first_name,last_name,email,status,account",
      "user_1,user1,User,Uno,user@example.com,active,foo"
    )
    user = CommunicationChannel.find_by_path('user@example.com').user
    foo_account.all_users.should include(user)
  end

  it "should create new user with enrollment_type" do
    foo_account = factory_with_protected_attributes(Account, {:name => "foo"})
    process_csv_data_cleanly(
      "user_id,login_id,first_name,last_name,email,status,account,enrollment_type",
      "user_1,user1,User,Uno,user@example.com,active,foo,student"
    )
    user = CommunicationChannel.find_by_path('user@example.com').user
    associate = UserAccountAssociation.find(:first, :conditions => { :user_id => user.id, :account_id => foo_account.id })
    associate.enrollment_type.should == "student"
  end

  it "should mark fake if user come form sis import" do
    foo_account = factory_with_protected_attributes(Account, {:name => "foo"})
    process_csv_data_cleanly(
      "user_id,login_id,first_name,last_name,email,status,account,enrollment_type",
      "user_1,user1,User,Uno,user@example.com,active,foo,student"
    )
    user = CommunicationChannel.find_by_path('user@example.com').user
    associate = UserAccountAssociation.find(:first, :conditions => { :user_id => user.id, :account_id => foo_account.id })
    associate.fake.should be_true
  end

  it "should reuse login_id and email if user already inmport form sis" do
    foo_account = factory_with_protected_attributes(Account, {:name => "foo"})
    process_csv_data_cleanly(
      "user_id,login_id,first_name,last_name,email,status,account,enrollment_type",
      "user_1,user1,User,Uno,user@example.com,active,foo,student"
    )
    lambda { CommunicationChannel.create!(:path => 'user@example.com') }.should_not raise_error
  end


end
