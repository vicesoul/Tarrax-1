# encoding: utf-8
#
#create_table "jxb_widgets", :force => true do |t|
#  t.string   "cell_name"
#  t.string   "cell_action"
#  t.string   "title"
#  t.text     "body"
#  t.string   "position"
#  t.integer  "seq"
#  t.integer  "page_id",     :limit => 8
#  t.datetime "created_at"
#  t.datetime "updated_at"
#  t.string   "courses"
#end
#
class Jxb::Widget < ActiveRecord::Base
  set_table_name 'jxb_widgets'

  belongs_to :page, :class_name => 'Jxb::Page'

  attr_accessible :cell_name, :cell_action, :title, :body, :position, :seq, :courses

  serialize :courses

  after_update :clear_cache
  
  # custom_index         自定义组件
  # assignment_index     作业列表组件
  # discussion_index     讨论列表组件
  # announcement_index   公告列表组件
  # activity_index       活动列表组件
  # announcement_account 网校公告组件
  # logo_index           logo组件
  # course_index         课程列表组件
  def self.types
    [
      %W( #{t(:custom_index, 'custom_index')}             custom_index ),
      %W( #{t(:activity_index, 'activity_index')}         activity_index ),
      %W( #{t(:announcement_index, 'announcement_index')} announcement_index ),
      %W( #{t(:discussion_index, 'discussion_index')}     discussion_index ),
      %W( #{t(:assignment_index, 'assignment_index')}     assignment_index ),
      %W( #{t(:announcement_account, 'account_announcement')}   announcement_account ),
      %W( #{t(:logo_index, 'logo_index')}   logo_index ),
      %W( #{t(:course_index, 'course_index')}   course_index )
    ]
  end
  
  def cell_data
    [cell_name, cell_action, id].join(',')
  end

  private
    
    def clear_cache
      Rails.cache.delete( "views/" + [self.page.context, "#{self.page.id}-content"].cache_key + "/#{I18n.locale}" ) rescue nil
    end

end
