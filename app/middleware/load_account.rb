class LoadAccount
  def initialize(app)
    @app = app
  end

  def call(env)
    Account.clear_special_account_cache!

    request = ActionController::Request.new(env)
    # share session in all subdomain
    env["rack.session.options"][:domain] = ".#{request.domain}"

    domain_root_account = account_from_request(request) || LoadAccount.default_domain_root_account
    configure_for_root_account(domain_root_account)

    env['canvas.domain_root_account'] = domain_root_account
    status, headers, response = @app.call(env)

    # setting domain_root_account_id in response's header
    headers['X-Canvas-Domain-Root-Account-Id'] = "#{domain_root_account.id}"
    [status, headers, response]
  end

  def account_from_request(request)
    subdomain = request.subdomains.join(".")
    # TODO redirect to Account.default url if not found
    Subdomain.find_by_subdomain(subdomain).try(:account)
  end

  def self.default_domain_root_account; Account.default; end

  protected

  def configure_for_root_account(domain_root_account)
    Attachment.domain_namespace = domain_root_account.file_namespace
  end
end
