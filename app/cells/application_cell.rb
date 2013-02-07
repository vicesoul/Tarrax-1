class ApplicationCell < ::Cell::Base
  helper_method :data_widget, :widget

  def data_widget
    "data-widget='#{widget.cell_data}'"
  end

  def widget
    @opts[:widget]
  end
  
  def page
    @opts[:page] || widget.page
  end

  def account
    @opts[:account] || page.account
  end

  def theme
    @opts[:theme] || page.theme
  end
end
