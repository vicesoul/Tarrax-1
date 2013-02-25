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
  
  # custom_index       自定义组件
  # assignment_index   作业列表组件
  # discussion_index   讨论列表组件
  # news_index         新闻列表组件
  # announcement_index 公告列表组件
  # activity_index     活动列表组件
  TYPE = [
    %W( #{t(:activity_index, 'activity_index')}         activity_index ),
    %W( #{t(:news_index, 'news_index')}                 news_index ),
    %W( #{t(:announcement_index, 'announcement_index')} announcement_index ),
    %W( #{t(:discussion_index, 'discussion_index')}     discussion_index ),
    %W( #{t(:assignment_index, 'assignment_index')}     assignment_index ),
    %W( #{t(:custom_index, 'custom_index')}             custom_index )
  ]
  
  def cell_data
    [cell_name, cell_action, id].join(',')
  end

end
