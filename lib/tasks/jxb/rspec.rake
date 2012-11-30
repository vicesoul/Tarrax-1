# Don't load rspec if running "rake gems:*"
unless ARGV.any? { |a| a =~ /\Agems/ }

  begin
    require 'spec/rake/spectask'
  rescue MissingSourceFile
    module Spec
      module Rake
        class SpecTask
          include ::Rake::DSL

          def initialize(name)
            task name do
              # if rspec-rails is a configured gem, this will output helpful material and exit ...
              require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")

              # ... otherwise, do this:
              raise <<-MSG

#{"*" * 80}
*  You are trying to run an rspec rake task defined in
*  #{__FILE__},
*  but rspec can not be found in vendor/gems, vendor/plugins or system gems.
#{"*" * 80}
              MSG
            end
          end
        end
      end
    end
  end

  namespace :jxb do
    
    desc "Run all specs in spec/**/jxb directory"
    Spec::Rake::SpecTask.new(:spec) do |t|
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList["spec/**/jxb/*_spec.rb"]
    end

  end

end
