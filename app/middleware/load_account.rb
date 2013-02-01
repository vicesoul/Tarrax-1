class LoadAccount
  def initialize(app)
    @app = app
  end

  def call(env)
    Account.clear_special_account_cache!

    request = ActionController::Request.new(env)
    # share session in all subdomain
    env["rack.session.options"][:domain] = ".#{request.domain}"

    if domain_root_account = account_from_request(request)
      configure_for_root_account(domain_root_account)

      env['canvas.domain_root_account'] = domain_root_account
      status, headers, response = @app.call(env)

      # setting domain_root_account_id in response's header
      headers['X-Canvas-Domain-Root-Account-Id'] = "#{domain_root_account.id}"
    else
      # redirect to default host if subdomain not matched
      uri = URI.parse request.url
      uri.host   = HostUrl.default_host.split(':').first

      status     = 301
      headers    = {'Location' => uri.to_s, 'Content-Type' => 'text/plain'}
      response   = ["Redirecting to canonical URL #{uri}"]
    end

    [status, headers, response]
  end

  def account_from_request(request)
    subdomain = request.subdomains.join(".")
    a = subdomain.blank? ? LoadAccount.default_domain_root_account : Subdomain.find_by_name(subdomain).try(:account)

    (a.nil? && Rails.env.test?) ? LoadAccount.default_domain_root_account : a
  end

  def self.default_domain_root_account; Account.default; end

  protected

  def configure_for_root_account(domain_root_account)
    Attachment.domain_namespace = domain_root_account.file_namespace
  end
end
