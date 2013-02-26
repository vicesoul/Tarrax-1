class ApplicationCell < ::Cell::Base
  cache :index, :expires_in => 5.minutes

  helper_method :data_widget, :widget, :extract_images, :title, :body, :context

  def data_widget
    "data-widget='#{widget.cell_data}'"
  end

  def extract_images(html)
    html && html.scan(/<img[^>]+>/) || []
  end

  def title(default_title)
    !widget.title.blank? && widget.title.strip || default_title
  end

  def body(default_body)
    !widget.body.blank? && widget.body.html_safe || default_body
  end

  def widget
    @opts[:widget]
  end
  
  def page
    @opts[:page] || widget.page
  end

  def context
    @opts[:context] || page.context
  end

  def theme
    @opts[:theme] || page.theme
  end

end
