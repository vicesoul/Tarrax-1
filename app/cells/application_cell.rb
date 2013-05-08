class ApplicationCell < ::Cell::Base
  cache :index, :expires_in => 5.minutes
  helper Jxb::WidgetsHelper
  helper_method :data_widget, :widget, :extract_images, :title, :context, :service_enabled?, :widget_body, :current_user, :current_session, :format_context

  def data_widget
    "data-widget=#{widget.cell_data}"
  end

  def extract_images(html)
    html && html.scan(/<img[^>]+>/) || []
  end

  def title(default_title)
    !widget.title.blank? && widget.title.strip || default_title
  end

  def format_contexts(contexts, can_select_course=true)
    if widget.page.context_type == 'User'
      can_select_course = false
      @opts[:user_can_select_course] = true
    end
    @opts[:can_select_course] = can_select_course
    if can_select_course
      @ids = widget.page.courses && widget.page.courses.map(&:to_i) || [] 
      @has_content = @ids & contexts.map{|obj| obj.context.id} != []
    else
      @has_content = true
    end
  end

  def format_context(kontext)
    course = kontext.context # Course
    user   = kontext.user
    result = {}
    result[:id] = course.id
    if user
      result[:user_url] = "/courses/#{course.id}/users/#{user.id}"
      result[:user_name] = user.short_name
    end
    result[:course_name] = course.name
    result[:url] = "/courses/#{course.id}/discussion_topics/#{kontext.id}"
    if kontext.instance_of?(DiscussionTopic)
      result[:topics_url] = "/courses/#{course.id}/discussion_topics"
    elsif kontext.instance_of?(Announcement)
      result[:topics_url] = "/courses/#{course.id}/announcements"
    end
    result
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

  def get_widget_courses
    course_ids = @opts[:widget][:courses]
    #compatible old data structure
    course_ids = course_ids.split(',') if course_ids.is_a?(String)
    course_ids.blank? ? nil : Course.find(course_ids)
  end

end
