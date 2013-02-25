class CustomCell < ApplicationCell

  def index
    prepend_view_path Jxb::Theme.widget_path(theme)

    render
  end

end
