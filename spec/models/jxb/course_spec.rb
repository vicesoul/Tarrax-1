require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe Course do
  context "course system" do
    before :each do
      account_model
      course_model :account => @account
    end
  end
end
