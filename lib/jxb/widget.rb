module Jxb
  module Widget
    
    TYPE = %w(user_index course_index)

    module Helper
      
      def widgets_at_position(position)
        return unless @homepage.positions and @homepage.positions[position]

        html = ''
        @homepage.positions[position].each do |widget|
          next if widget == "" or widget !~ /_widget\z/
          next unless respond_to?(widget)
          html += send(widget)
        end
        html.html_safe
      end
      
      def user_index_widget
        render_cell :user, :index, :account => @account, :theme => @homepage.theme
      end

      def course_index_widget
        render_cell :course, :index, :account => @account, :theme => @homepage.theme
      end

    end

  end
end
