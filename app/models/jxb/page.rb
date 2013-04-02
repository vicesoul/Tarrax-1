#create_table "jxb_pages", :force => true do |t|
#  t.string   "name"
#  t.string   "theme",      :default => "jxb"
#  t.integer  "context_id", :limit => 8
#  t.string   "courses"
#  t.string   "background_image"
#  t.datetime "created_at"
#  t.datetime "updated_at"
#end
#
class Jxb::Page < ActiveRecord::Base
  set_table_name 'jxb_pages'
  
  has_many :widgets, :class_name => 'Jxb::Widget', :dependent => :destroy, :order => 'seq'

  belongs_to :context, :polymorphic => true

  attr_accessible :name, :theme, :positions, :courses, :background_image
  serialize :courses
  
  after_update :save_widgets
  after_update :clear_cache

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:context_id, :context_type]
  
  set_policy do
    
    # any user with an association to this page's account can read
    given { |user,session| 
      if self.context.is_a?(Account)
        if self.context.settings[:allow_homepage_previews]
          true
        else
          user && self.context.user_account_associations.find_by_user_id(user.id)
        end
      elsif self.context.is_a?(User)
        user == self.context
      end
    }
    can :read

  end
  
  # positions => { '1_0' => {'body' => '', 'title' => '', 'widget' => ''} }
  def positions=(positions)
    cache_widgets = self.widgets.inject({}){ |h,widget| h[widget.id.to_s] = widget;h }
    positions.each do |position, data|
      data[:cell_name], data[:cell_action], id = data.delete('widget').split(',')
      data[:position], data[:seq] = position.split('_')
      widget = id && cache_widgets[id] || self.widgets.build
      if !widget.new_record? && data[:delete]
        widget.destroy
      else
        widget.attributes = data
      end
    end # End of positions#each
  end

  private

    def save_widgets
      widgets.each{ |widget|
        if widget.new_record?
          widget.send(:create_without_callbacks)
        else
          widget.send(:update_without_callbacks)
        end
      }
    end

    def clear_cache
      Rails.cache.delete( "views/" + [self.context, "#{self.id}-content"].cache_key + "/#{I18n.locale}" ) rescue nil
    end

end
