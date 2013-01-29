module Jxb
  module Theme
    
    BASE_DIR = File.join(Rails.root, 'themes')

    def self.themes
      @_themes ||=  Dir.entries(Jxb::Theme::BASE_DIR).reject{ |d|
        not File.directory?( File.join(Jxb::Theme::BASE_DIR, d) ) or d == '.' or d == '..'
      }
    end

    def self.path(name)
      File.join BASE_DIR, name
    end

    def self.widget_path(name)
      File.join BASE_DIR, "#{name}/widgets"
    end

  end
end
