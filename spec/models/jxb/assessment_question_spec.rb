require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe AssessmentQuestion do
  
  it "should allow img tag with src contain data source" do
    html = "<p>foo</p>\n<p><img title=\"bar\" src=\"data:image/png;base64\" /></p>"
    expected = "<p>foo</p>\n<p><img title=\"bar\" src=\"data:image/png;base64\"></p>"
    AssessmentQuestion.sanitize(html).should == expected
  end

  it "should allow html style attribute contain background infos" do
    html1 = "<p style=\"background-image: url(foo);\">foo</p>"
    AssessmentQuestion.sanitize(html1).should == html1
    html = "<p style=\"background-image: url(https://farm6.static.flickr.com/5254/5566459337_abc140b4cb.jpg);\">foo</p>"
    AssessmentQuestion.sanitize(html).should == html
    html2 = "<p style=\"background: url(https://192.168.1.101:3000/5254/5566459337_abc140b4cb.jpg) no-repeat;\">foo</p>"
    AssessmentQuestion.sanitize(html2).should == html2
  end

  it "should allow those style attributes" do
    expected = "background: url( http://192.168.0.189:3000/courses/1/files/7/preview ) no-repeat scroll 0 0 transparent;max-height: 165px;max-width: 211px;min-height: 165px;min-width: 211px;"
    AssessmentQuestion.sanitize(expected).should == expected
    expected1 = "background:url( http://192.168.0.189:3000/files/7/download?verifier=BZEwpP2twf1QbpWOQvcTCQw6EtvhpSx0atsBZzlR ) no-repeat;max-width:165px;min-width:165px;max-height:165px;min-height:165px;"
    AssessmentQuestion.sanitize(expected1).should == expected1
  end
  
end
