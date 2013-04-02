module Jxb
  module Theme
    
    BASE_DIR = File.join(Rails.root, 'themes')
    BASE_STATIC_DIR = File.join(Rails.root, 'public', 'themes')

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

    def self.css_paths(name)
      cssfiles = File.join(BASE_STATIC_DIR, name, 'stylesheets', '*.css')
      Dir[cssfiles].map{|s| css_path(s, name) }
    end

    def self.css_path(source, name)
      "/themes/#{name}/stylesheets/#{source}"
    end

  end
end
