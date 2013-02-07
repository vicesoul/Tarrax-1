#create_table "jxb_pages", :force => true do |t|
#  t.string   "name"
#  t.string   "theme",      :default => "jxb"
#  t.integer  "account_id", :limit => 8
#  t.text     "positions"
#  t.datetime "created_at"
#  t.datetime "updated_at"
#end
#
class Jxb::Page < ActiveRecord::Base
  set_table_name 'jxb_pages'
  
  has_many :widgets, :class_name => 'Jxb::Widget', :dependent => :destroy
  belongs_to :account

  attr_accessible :name, :theme, :positions
  
  after_update :save_widgets

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:account_id]
  
  set_policy do
    
    # any user with an association to this page's account can read
    given { |user,session| user && self.account.user_account_associations.find_by_user_id(user.id) }
    can :read

  end
  
  # positions => { '1_0' => {'body' => '', 'title' => '', 'widget' => ''} }
  def positions=(positions)
    cache_widgets = self.widgets.inject({}){ |h,widget| h[widget.id.to_s] = widget;h }
    positions.each do |position, data|
      data[:cell_name], data[:cell_action], id = data.delete('widget').split(',')
      data[:position], data[:seq] = position.split('_')
      widget = id && cache_widgets[id] || self.widgets.build
      widget.attributes = data
    end # End of positions#each
  end

  private

  def save_widgets
    widgets.each{|widget| widget.save }
  end

end
