require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe Jxb::Page do
  
  before :each do
    @account  = Account.create
    @homepage = @account.create_homepage :name => 'homepage'
    @widget1  = Jxb::Widget.create :cell_name => 'foo', :cell_action => 'index'
    @widget2  = Jxb::Widget.create :cell_name => 'bar', :cell_action => 'index'
    @homepage.widgets << @widget1
    @homepage.widgets << @widget2
  end

  it "should belong to a context" do
    @homepage.context_id.should == @account.id
  end

  it "should have many widgets" do
    @homepage.widgets.should == [@widget1,@widget2]
  end

  it "should destroy all widgets when page destroyed" do
    @homepage.destroy
    Jxb::Widget.find_by_id(@widget1.id).should be_nil
    Jxb::Widget.find_by_id(@widget2.id).should be_nil
  end

  it "should validate presence of name" do
    lambda { Jxb::Page.create! }.should raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it "should validate uniqueness of name under account scope" do
    page1 = Jxb::Page.new(:name => 'foo')
    page1.context_id = 1
    page1.save!
    lambda { 
      page2 = Jxb::Page.new(:name => 'foo')
      page2.context_id = 1
      page2.save!
    }.should raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
    lambda { 
      page3 = Jxb::Page.new(:name => 'foo')
      page3.context_id = 2
      page3.save!
    }.should_not raise_error
  end

  it "should have default theme jiaoxuebang" do
    @homepage.theme.should == 'jiaoxuebang'
  end
  
  context "positions" do
    
    it "should save widgets" do
      params = { :name => 'foo', 
                 :theme => 'bar', 
                 :positions => { 'p1_0' => {'body' => '<h1>i am logo</h1>', 'title' => 'title1', 'widget' => 'user,index'},
                                 'p1_1' => {'body' => 'barbarbar', 'title' => 'fly', 'widget' => 'ch,ina'}
                  }
      }

      page = Jxb::Page.create(params)
      page.reload # Need reload to refresh order. maybe it's a rails bug
      page.name.should == 'foo'
      page.theme.should == 'bar'
      page.widgets.size.should == 2
      widget = page.widgets.first
      widget.position.should == 'p1'
      widget.seq.should == 0
      widget.cell_name.should == 'user'
      widget.cell_action.should == 'index'
      widget.title.should == 'title1'
      widget.body.should == '<h1>i am logo</h1>'
    end

    it "should update widgets when privoid id" do
      page = Jxb::Page.create(:name => 'foo', :theme => 'bar')
      widget = page.widgets.create :cell_name => 'oo', :cell_action => 'aa'
      params = { :positions => { 'p1_0' => {'widget' => "user,index,#{widget.id}",'body' => '<h1>i am logo</h1>','title' => 'title1'} } }
      page.update_attributes(params)
      page.widgets.size.should == 1
      widget.position.should == 'p1'
      widget.seq.should == 0
      widget.cell_name.should == 'user'
      widget.cell_action.should == 'index'
      widget.title.should == 'title1'
      widget.body.should == '<h1>i am logo</h1>'

    end

    it "should not save widgets if save page error" do
      pending
    end

    it "should delete widget" do
      page = Jxb::Page.create(:name => 'foo', :theme => 'bar')
      widget = page.widgets.create :cell_name => 'oo', :cell_action => 'aa'
      params = { :positions => { 'p1_0' => {'widget' => "user,index,#{widget.id}", :delete => '1', 'body' => '<h1>i am logo</h1>','title' => 'title1'} } }
      page.update_attributes(params)
      page.reload
      page.widgets.size.should == 0
      Jxb::Widget.find_by_id(widget.id).should be_nil
    end

  end


end
