# copy from http://asciicasts.com/episodes/221-subdomains-in-rails-3
module UrlHelper
  def with_subdomain(subdomain)
    subdomain = (subdomain.to_s || "www")
    subdomain += "." unless subdomain.empty?
    [subdomain, request.domain, request.port_string].join
  end

  def url_for(options = nil)
    if options.kind_of?(Hash)
      if options.has_key?(:context_host)
        options[:host] = options.delete(:context_host)
      elsif options.has_key?(:subdomain)
        options[:host] = with_subdomain(options.delete(:subdomain))
      end
    end
    super
  end
end

