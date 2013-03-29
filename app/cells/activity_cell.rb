class ActivityCell < ApplicationCell

  def index
    @imgs = extract_images(widget_body)

    if @opts[:limit]
      limit = @opts[:limit].to_i - 1
      @imgs = @imgs[0..limit] if limit >= 0
    end

    prepend_view_path Jxb::Theme.widget_path(theme)
    
    render
  end

end
