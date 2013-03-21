class ActivityCell < ApplicationCell

  def index
    @imgs = extract_images(widget_body)

    prepend_view_path Jxb::Theme.widget_path(theme)
    
    render
  end

end
