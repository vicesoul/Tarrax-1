
module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Backends
      # Methods for file system backed attachments
      module SndaBackend
        def self.included(base) #:nodoc:
          base.before_update :rename_file

          begin 
            require 'sndacs'
          rescue LoadError
            raise RequiredLibraryNotFoundError.new('SNDA could not be loaded')
          end

          begin
            @@s3_config_path = base.attachment_options[:s3_config_path] || (RAILS_ROOT + '/config/amazon_s3.yml')
            @@s3_config = @@s3_config = YAML.load(ERB.new(File.read(@@s3_config_path)).result)[RAILS_ENV].symbolize_keys
            @@service = Sndacs::Service.new(
              :access_key_id => @@s3_config[:access_key_id],
              :secret_access_key => @@s3_config[:secret_access_key]
            )
          rescue
            raise ConfigFileNotFoundError.new('File %s not found' % @@s3_config_path)
          end

          @@bucket_name = @@s3_config[:bucket_name]

          # Bucket.create(@@bucket_name)

          base.before_update :rename_file
        end

        def self.protocol
          @protocol ||= @@s3_config[:use_ssl] ? 'https://' : 'http://'
        end

        def self.hostname
          @hostname ||= @@s3_config[:server] || "storage.sdcloud.cn"
        end

        def self.port_string
          @port_string ||= (@@s3_config[:port].nil? || @@s3_config[:port] == (@@s3_config[:use_ssl] ? 443 : 80)) ? '' : ":#{@@s3_config[:port]}"
        end

        module ClassMethods
          def s3_protocol
            Technoweenie::AttachmentFu::Backends::SndaBackend.protocol
          end

          def s3_hostname
            Technoweenie::AttachmentFu::Backends::SndaBackend.hostname
          end

          def s3_port_string
            Technoweenie::AttachmentFu::Backends::SndaBackend.port_string
          end
        end

        # Overwrites the base filename writer in order to store the old filename
        def filename=(value)
          @old_filename = filename unless filename.nil? || @old_filename
          write_attribute :filename, sanitize_filename(value)
        end

        # The attachment ID used in the full path of a file
        def attachment_path_id
          ((respond_to?(:parent_id) && parent_id) || id).to_s
        end

        # INSTRUCTURE: fallback to old path style if there is no cluster attribute
        def namespaced_path
          obj = (respond_to?(:root_attachment) && self.root_attachment) || self
          if namespace = obj.read_attribute(:namespace)
            File.join(namespace, obj.attachment_options[:path_prefix])
          else
            obj.attachment_options[:path_prefix]
          end
        end

        # The pseudo hierarchy containing the file relative to the bucket name
        # Example: <tt>:table_name/:id</tt>
        def base_path
          File.join(namespaced_path, attachment_path_id)
        end

        # The full path to the file relative to the bucket name
        # Example: <tt>:table_name/:id/:filename</tt>
        def full_filename(thumbnail = nil)
          File.join(base_path, thumbnail_name_for(thumbnail))
        end

        # All public objects are accessible via a GET request to the S3 servers. You can generate a 
        # url for an object using the s3_url method.
        #
        #   @photo.s3_url
        #
        # The resulting url is in the form: <tt>http(s)://:server/:bucket_name/:table_name/:id/:file</tt> where
        # the <tt>:server</tt> variable defaults to <tt>AWS::S3 URL::DEFAULT_HOST</tt> (s3.amazonaws.com) and can be
        # set using the configuration parameters in <tt>RAILS_ROOT/config/amazon_s3.yml</tt>.
        #
        # The optional thumbnail argument will output the thumbnail's filename (if any).
        def s3_url(thumbnail = nil)
          File.join(s3_protocol + s3_hostname + s3_port_string, bucket_name, full_filename(thumbnail))
        end
        alias :public_filename :s3_url

        # All private objects are accessible via an authenticated GET request to the S3 servers. You can generate an 
        # authenticated url for an object like this:
        #
        #   @photo.authenticated_s3_url
        #
        # By default authenticated urls expire 5 minutes after they were generated.
        #
        # Expiration options can be specified either with an absolute time using the <tt>:expires</tt> option,
        # or with a number of seconds relative to now with the <tt>:expires_in</tt> option:
        #
        #   # Absolute expiration date (October 13th, 2025)
        #   @photo.authenticated_s3_url(:expires => Time.mktime(2025,10,13).to_i)
        #   
        #   # Expiration in five hours from now
        #   @photo.authenticated_s3_url(:expires_in => 5.hours)
        #
        # You can specify whether the url should go over SSL with the <tt>:use_ssl</tt> option.
        # By default, the ssl settings for the current connection will be used:
        #
        #   @photo.authenticated_s3_url(:use_ssl => true)
        #
        # Finally, the optional thumbnail argument will output the thumbnail's filename (if any):
        #
        #   @photo.authenticated_s3_url('thumbnail', :expires_in => 5.hours, :use_ssl => true)
        def authenticated_s3_url(*args)
          thumbnail = args.first.is_a?(String) ? args.first : nil
          options   = args.last.is_a?(Hash)    ? args.last  : {}
          #commented by Tim
          #S3Object.url_for(full_filename(thumbnail), bucket_name, options)
        end

        def create_temp_file
          write_to_temp_file current_data
        end

        def current_data
          @@service.buckets.find(@@bucket_name).objects.find(full_filename).content
        end

        def s3_protocol
          Technoweenie::AttachmentFu::Backends::SndaBackend.protocol
        end

        def s3_hostname
          Technoweenie::AttachmentFu::Backends::SndaBackend.hostname
        end

        def s3_port_string
          Technoweenie::AttachmentFu::Backends::SndaBackend.port_string
        end

        protected
        # Called in the after_destroy callback
        def destroy_file
          # Not confident that a monkey patch will always work for a plugin.  Changing inline.
          begin
            @@service.buckets.find(@@bucket_name).objects.find(full_filename).destroy
          rescue
            # full_filename will break if the transmission didn't work.
            true
          end
        end

        def rename_file
          # INSTRUCTURE: We don't actually want to rename Attachments.
          # The problem is that we're re-using our s3 storage if you copy
          # a file or if two files have the same md5 and size.  In that case
          # there are multiple attachments pointing to the same place on s3
          # and we don't want to get rid of the original... 
          # TODO: we'll just have to figure out a different way to clean out
          # the cruft that happens because of this
          return
          return unless @old_filename && @old_filename != filename

          old_full_filename = File.join(base_path, @old_filename)

          # INSTRUCTURE: this dies when the file did not already exist,
          # but we need it to not throw an angry exception in production.
          # I've added some additional provisions in Attachment.rb, but
          # it looks like they're not always working for some reason
          begin
          #commented by Tim
            #S3Object.rename(
              #old_full_filename,
              #full_filename,
              #bucket_name,
              #:access => attachment_options[:s3_access]
            #)
          rescue => e
            filename = @old_filename
          end

          @old_filename = nil
          true
        end

        def save_to_storage
          debugger
          if save_attachment?
            new_object = @@service.buckets.find(@@bucket_name).objects.build(full_filename)
            new_object.content = temp_data
            new_object.save
          end

          @old_filename = nil
          true
        end
      end
    end
  end
end
