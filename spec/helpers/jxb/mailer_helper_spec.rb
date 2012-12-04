require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MailerHelper do
  
  it "should convert text to html" do
    text = "You received this email because you are participating in one or more classes using\nhttp://www.baidu.com"
    html = "<p>You received this email because you are participating in one or more classes using\n<br /><a href=\"http://www.baidu.com\">http://www.baidu.com</a></p>"
    MailerHelper.text_to_html(text).should ==  html
  end

end
