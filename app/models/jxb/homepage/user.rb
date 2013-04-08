module Jxb
  module Homepage
    module User
      def self.included(base)
        base.class_eval do
          has_one :dashboard_page, :as => :context, :class_name => 'Jxb::Page', :dependent => :destroy

          attr_accessible :account_id
          attr_accessor   :account_id
        end
      end

      include Jxb::CommonBehavior

      def find_or_create_dashboard_page
        self.dashboard_page || begin
          courses = self.available_courses.map{|c| c.id}.join(',')
          page = self.build_dashboard_page(:name => 'dashboard', :theme => 'jiaoxuebang')
          page.widgets.build(:cell_name => "announcement", :cell_action => "index", :seq => 1, :courses => courses)
          page.widgets.build(:cell_name => "assignment",   :cell_action => "index", :seq => 2, :courses => courses)
          page.widgets.build(:cell_name => "discussion",   :cell_action => "index", :seq => 3, :courses => courses)
          page.save
          page
        end
      end

      def activity_widget_body
        page_ids = Jxb::Page.find( :all, :conditions => [ "name = 'homepage' AND context_type = ? AND context_id IN (?)", 'Account', self.associated_account_ids ] ).map{ |page| page.id }
        Jxb::Widget.find( :all, :conditions => [ "cell_name = 'activity' AND cell_action = 'index' AND page_id IN (?)", page_ids.uniq ], :order => "updated_at DESC" ).map{ |widget| widget.body }.compact.join("\n")
      end

    end
  end
end
