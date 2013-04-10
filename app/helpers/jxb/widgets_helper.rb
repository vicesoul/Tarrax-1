module Jxb::WidgetsHelper

  def widgets_at_position(position)
    @widgets = @page.widgets.where(:position => position)
    return if @widgets.blank?

    html = ''
    @widgets.each do |widget|
      courses = Course.find(@page.courses) rescue nil
      html += render_widget( widget, :courses => courses )
    end
    html.html_safe
  end

  def widgets_at_position_as_link(position, can_manage = false)
    widgets = @page.widgets.where(:position => position)
    return if widgets.blank?

    links = html = ''
    widgets.each do |widget|
      links += link_to( widget.title, widget_path(widget), :target => '_blank' )
      if can_manage
        courses = Course.find(@page.courses) rescue nil
        html += render_widget( widget, :courses => courses )
      end
    end
    (links + html).html_safe
  end

  def render_widget(widget, options = {})
    render_cell( widget.cell_name, widget.cell_action, options.merge(:widget  => widget) )
  end

  def new_widget(name)
    cell_name, cell_action = name.split('_')
    widget = @page.widgets.build(:cell_name => cell_name, :cell_action => cell_action)
    render_widget(widget)
  end

end
