require "uri"

class AssumeLocalHttpsProxy
  LOCALHOST_SUFFIX = ".localhost"

  def initialize(app)
    @app = app
  end

  def call(env)
    assume_https(env) if matching_https_localhost_origin?(env)

    @app.call(env)
  end

  private
    def matching_https_localhost_origin?(env)
      uri = URI.parse(env["HTTP_ORIGIN"].to_s)

      uri.scheme == "https" && local_host?(uri.host) && uri.host == request_host(env)
    rescue URI::InvalidURIError
      false
    end

    def local_host?(host)
      host == "localhost" || host&.end_with?(LOCALHOST_SUFFIX)
    end

    def request_host(env)
      host = env["HTTP_HOST"].to_s
      host = env["SERVER_NAME"].to_s if host.empty?
      host.split(":").first
    end

    def assume_https(env)
      env["HTTPS"] = "on"
      env["rack.url_scheme"] = "https"
      env["SERVER_PORT"] = "443" if env["SERVER_PORT"] == "80"
    end
end
