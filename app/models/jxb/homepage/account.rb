module Jxb
  module Homepage
    module Account
      def self.included(base)
        base.class_eval do
          has_one :homepage, :as => :context, :class_name => 'Jxb::Page', :dependent => :destroy
          has_many :case_tpls, :as => :context, :conditions => ['workflow_state != ?', 'deleted']
        end
      end

      include Jxb::CommonBehavior

      def find_or_create_homepage
        self.homepage || begin
          # use jiaoxuebang as default theme
          # course index widget if root account
          # account announcement
          # activity wiget
          # logo widget
          page = self.build_homepage(:name => 'homepage', :theme => 'jiaoxuebang')
          #page.widgets.build(
            #:cell_name => 'logo', 
            #:cell_action => 'index', 
            #:body => "#{self.name}",
            #:position => 'caption'
          #)
          page.widgets.build(
            :cell_name => 'activity',
            :cell_action => 'index',
            :position => 'center',
            :seq => 0,
            :body => '<img src="/themes/jiaoxuebang/img/demo1.jpg" alt="demo1"/><img src="/themes/jiaoxuebang/img/demo2.jpg" alt="demo2"/><img src="/themes/jiaoxuebang/img/demo3.jpg" alt="demo3"/>'
          )
          page.widgets.build(
            :cell_name => 'course',
            :cell_action => 'index',
            :position => 'center',
            :seq => 1
          ) if self.root_account?
          page.widgets.build(
            :cell_name => 'announcement',
            :cell_action => 'index',
            :position => 'center',
            :seq => 2
          )
          page.widgets.build(
            :cell_name => 'discussion',
            :cell_action => 'index',
            :position => 'center',
            :seq => 3
          )
          page.widgets.build(
            :cell_name => 'announcement',
            :cell_action => 'account',
            :position => 'right',
            :seq => 0
          )
          page.save
          page
        end
      end

      def update_courses_be_part_of
        courses.each do |course|
          course.is_public = course.indexed = self.settings[:public_account]
          course.save
        end
      end

    end
  end
end
