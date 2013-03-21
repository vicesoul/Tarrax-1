class ApplicationCell < ::Cell::Base
  cache :index, :expires_in => 5.minutes

  helper_method :data_widget, :widget, :extract_images, :title, :context, :service_enabled?, :widget_body, :current_user, :current_session

  def data_widget
    "data-widget='#{widget.cell_data}'"
  end

  def extract_images(html)
    html && html.scan(/<img[^>]+>/) || []
  end

  def title(default_title)
    !widget.title.blank? && widget.title.strip || default_title
  end

  def format_contexts(contexts)
    if @opts[:can_select_course]
      @ids = widget.courses && widget.courses.split(",").map(&:to_i) || [] 
      @has_content = @ids & contexts.map{|obj| obj.context.id} != []
    else
      @has_content = true
    end
  end

  def service_enabled?(service)
    @domain_root_account && @domain_root_account.service_enabled?(service)
  end

  def widget
    @opts[:widget] || Jxb::Widget.new
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

  def widget_body
    @opts[:widget_body] || widget.body
  end

  def current_user
    @opts[:current_user]
  end

  def current_session
    @opts[:current_session]
  end

end
