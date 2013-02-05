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
#end
#
class Jxb::Widget < ActiveRecord::Base
  set_table_name 'jxb_widgets'
  
  belongs_to :page, :class_name => 'Jxb::Page'

  TYPE = %w(user_index course_index banner_index)
  
  def cell_data
    [cell_name, cell_action, id, title, body].join(',')
  end

end
