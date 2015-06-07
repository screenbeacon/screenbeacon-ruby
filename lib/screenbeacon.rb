# Screenbeacon Ruby bindings
# API spec at https://screenbeacon.readme.io
require 'cgi'
require 'openssl'
require 'rbconfig'
require 'set'
require 'socket'

require 'rest-client'
require 'json'

# Version
require_relative 'screenbeacon/version'

# API operations
require_relative 'screenbeacon/api_operations/create'
require_relative 'screenbeacon/api_operations/update'
require_relative 'screenbeacon/api_operations/delete'
require_relative 'screenbeacon/api_operations/list'
require_relative 'screenbeacon/api_operations/request'

# Resources
require_relative 'screenbeacon/util'
require_relative 'screenbeacon/screenbeacon_object'
require_relative 'screenbeacon/api_resource'
require_relative 'screenbeacon/project'
require_relative 'screenbeacon/test'
require_relative 'screenbeacon/alert'

# Errors
require_relative 'screenbeacon/errors/screenbeacon_error'
require_relative 'screenbeacon/errors/api_error'
require_relative 'screenbeacon/errors/api_connection_error'
require_relative 'screenbeacon/errors/invalid_request_error'
require_relative 'screenbeacon/errors/authentication_error'

module Screenbeacon
  DEFAULT_CA_BUNDLE_PATH = File.dirname(__FILE__) + '/data/ca-certificates.crt'
  @api_base = 'https://api.screenbeacon.com'

  @ssl_bundle_path  = DEFAULT_CA_BUNDLE_PATH
  @verify_ssl_certs = true


  class << self
    attr_accessor :api_id, :api_token, :api_base, :verify_ssl_certs, :api_version #, :connect_base, :uploads_base
  end

  def self.api_url(url='', api_base_url=nil)
    (api_base_url || @api_base) + url
  end

  def self.request(method, url, api_id, api_token, params={}, headers={}, api_base_url=nil)
    api_base_url = api_base_url || @api_base

    unless api_id ||= @api_id
      raise AuthenticationError.new('No API ID provided. ' \
        'Set your API ID using "Screenbeacon.api_id = <API-ID>". ' \
        'You can generate API ID from the Screenbeacon web interface. ' \
        'See https://screenbeacon.com/dashboard/settings for details, or email support@screenbeacon.com ' \
        'if you have any questions.')
    end

    unless api_token ||= @api_token
      raise AuthenticationError.new('No API token provided. ' \
        'Set your API token using "Screenbeacon.api_token = <API-TOKEN>". ' \
        'You can generate API token from the Screenbeacon web interface. ' \
        'See https://screenbeacon.com/dashboard/settings for details, or email support@screenbeacon.com ' \
        'if you have any questions.')
    end

    if api_id =~ /\s/
      raise AuthenticationError.new('Your API key is invalid, as it contains ' \
        'whitespace. (HINT: You can double-check your API key from the ' \
        'Screenbeacon web interface. See https://screenbeacon.com/dashboard/settings for details, or ' \
        'email support@screenbeacon.com if you have any questions.)')
    end

    if api_token =~ /\s/
      raise AuthenticationError.new('Your API token is invalid, as it contains ' \
        'whitespace. (HINT: You can double-check your API token from the ' \
        'Screenbeacon web interface. See https://screenbeacon.com/dashboard/settings for details, or ' \
        'email support@screenbeacon.com if you have any questions.)')
    end

    if verify_ssl_certs
      request_opts = {:verify_ssl => OpenSSL::SSL::VERIFY_PEER,
                      :ssl_ca_file => @ssl_bundle_path}
    else
      request_opts = {:verify_ssl => false}
      unless @verify_ssl_warned
        @verify_ssl_warned = true
        $stderr.puts("WARNING: Running without SSL cert verification. " \
          "You should never do this in production. " \
          "Execute 'Screenbeacon.verify_ssl_certs = true' to enable verification.")
      end
    end

    params = Util.objects_to_ids(params)
    url = api_url(url, api_base_url)

    case method.to_s.downcase.to_sym
    when :get, :head, :delete
      # Make params into GET parameters
      url += "#{URI.parse(url).query ? '&' : '?'}#{uri_encode(params)}" if params && params.any?
      payload = nil
    else
      if headers[:content_type] && headers[:content_type] == "multipart/form-data"
        payload = params
      else
        payload = uri_encode(params)
      end
    end

    request_opts.update(:headers => request_headers(api_id, api_token).update(headers),
                        :method => method, :open_timeout => 30,
                        :payload => payload, :url => url, :timeout => 80)

    begin
      response = execute_request(request_opts)
    rescue SocketError => e
      handle_restclient_error(e, api_base_url)
    rescue NoMethodError => e
      # Work around RestClient bug
      if e.message =~ /\WRequestFailed\W/
        e = APIConnectionError.new('Unexpected HTTP response code')
        handle_restclient_error(e, api_base_url)
      else
        raise
      end
    rescue RestClient::ExceptionWithResponse => e
      if rcode = e.http_code and rbody = e.http_body
        handle_api_error(rcode, rbody)
      else
        handle_restclient_error(e, api_base_url)
      end
    rescue RestClient::Exception, Errno::ECONNREFUSED => e
      handle_restclient_error(e, api_base_url)
    end

    [parse(response), api_id, api_token]
  end

  private

  def self.user_agent
    @uname ||= get_uname
    lang_version = "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"

    {
      :bindings_version => Screenbeacon::VERSION,
      :lang => 'ruby',
      :lang_version => lang_version,
      :platform => RUBY_PLATFORM,
      :engine => defined?(RUBY_ENGINE) ? RUBY_ENGINE : '',
      :publisher => 'screenbeacon',
      :uname => @uname,
      :hostname => Socket.gethostname,
    }

  end

  def self.get_uname
    if File.exist?('/proc/version')
      File.read('/proc/version').strip
    else
      case RbConfig::CONFIG['host_os']
      when /linux|darwin|bsd|sunos|solaris|cygwin/i
        _uname_uname
      when /mswin|mingw/i
        _uname_ver
      else
        "unknown platform"
      end
    end
  end

  def self._uname_uname
    (`uname -a 2>/dev/null` || '').strip
  rescue Errno::ENOMEM # couldn't create subprocess
    "uname lookup failed"
  end

  def self._uname_ver
    (`ver` || '').strip
  rescue Errno::ENOMEM # couldn't create subprocess
    "uname lookup failed"
  end


  def self.uri_encode(params)
    Util.flatten_params(params).
      map { |k,v| "#{k}=#{Util.url_encode(v)}" }.join('&')
  end

  def self.request_headers(api_id, api_token)
    headers = {
      :user_agent => "Screenbeacon/v1 RubyBindings/#{Screenbeacon::VERSION}",
      # :authorization => "Bearer #{api_id}",
      :content_type => 'application/x-www-form-urlencoded'
    }

    headers['Screenbeacon-Version'] = api_version if api_version
    headers['X-API-ID'] = api_id
    headers['X-API-TOKEN'] = api_token

    begin
      headers.update(:x_screenbeacon_client_user_agent => JSON.generate(user_agent))
    rescue => e
      headers.update(:x_screenbeacon_client_raw_user_agent => user_agent.inspect,
                     :error => "#{e} (#{e.class})")
    end
  end

  def self.execute_request(opts)
    RestClient::Request.execute(opts)
  end

  def self.parse(response)
    begin
      # Would use :symbolize_names => true, but apparently there is
      # some library out there that makes symbolize_names not work.
      response = JSON.parse(response.body)
    rescue JSON::ParserError
      raise general_api_error(response.code, response.body)
    end

    Util.symbolize_names(response)
  end

  def self.general_api_error(rcode, rbody)
    APIError.new("Invalid response object from API: #{rbody.inspect} " +
                 "(HTTP response code was #{rcode})", rcode, rbody)
  end

  def self.handle_api_error(rcode, rbody)
    begin
      error_obj = JSON.parse(rbody)
      error_obj = Util.symbolize_names(error_obj)
      error = error_obj[:error] or raise ScreenbeaconError.new # escape from parsing

    rescue JSON::ParserError, ScreenbeaconError
      raise general_api_error(rcode, rbody)
    end

    case rcode
    when 400, 404
      raise invalid_request_error error, rcode, rbody, error_obj
    when 401
      raise authentication_error error, rcode, rbody, error_obj
    when 402
      raise card_error error, rcode, rbody, error_obj
    else
      raise api_error error, rcode, rbody, error_obj
    end

  end

  def self.invalid_request_error(error, rcode, rbody, error_obj)
    # We're not returning a params as part of the error for now, so set it to nil.
    InvalidRequestError.new(error, nil, rcode, rbody, error_obj)
  end

  def self.authentication_error(error, rcode, rbody, error_obj)
    AuthenticationError.new(error, rcode, rbody, error_obj)
  end

  def self.api_error(error, rcode, rbody, error_obj)
    APIError.new(error, rcode, rbody, error_obj)
  end

  def self.handle_restclient_error(e, api_base_url=nil)
    api_base_url = @api_base unless api_base_url
    connection_message = "Please check your internet connection and try again. " \
        "If this problem persists, you should check Screenbeacon's service status at " \
        "https://twitter.com/screenbeacon, or let us know at support@screenbeacon.com."

    case e
    when RestClient::RequestTimeout
      message = "Could not connect to Screenbeacon (#{api_base_url}). #{connection_message}"

    when RestClient::ServerBrokeConnection
      message = "The connection to the server (#{api_base_url}) broke before the " \
        "request completed. #{connection_message}"

    when RestClient::SSLCertificateNotVerified
      message = "Could not verify Screenbeacon's SSL certificate. " \
        "Please make sure that your network is not intercepting certificates. " \
        "(Try going to https://api.screenbeacon.com in your browser.) " \
        "If this problem persists, let us know at support@screenbeacon.com."

    when SocketError
      message = "Unexpected error communicating when trying to connect to Screenbeacon. " \
        "You may be seeing this message because your DNS is not working. " \
        "To check, try running 'host screenbeacon.com' from the command line."

    else
      message = "Unexpected error communicating with Screenbeacon. " \
        "If this problem persists, let us know at support@screenbeacon.com."

    end

    raise APIConnectionError.new(message + "\n\n(Network error: #{e.message})")
  end
end
