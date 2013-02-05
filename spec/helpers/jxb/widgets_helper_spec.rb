require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Jxb::WidgetsHelper do
  
  before :each do
    account_model
    @page = @account.create_homepage :name => 'homepage'
    assigns[:page] = @page
    helper.stubs(:render_cell).returns('foo')
  end

  it "should render widget" do
    widget = mock(:cell_name => 'foo', :cell_action => 'bar')
    helper.render_widget(widget).should == 'foo'
  end

  it "should render new widget" do
    helper.new_widget('user_index').should == 'foo'
  end

  it "should return nil if special position has no widgets" do
    helper.widgets_at_position('lala').should be_nil
  end

  it "should outputs widgets at special position" do
    2.times do
      @page.widgets.create :position => 'Hah', :cell_name => 'jb', :cell_action => 'qs'
    end
    helper.widgets_at_position('Hah').should == 'foofoo'
  end

end
