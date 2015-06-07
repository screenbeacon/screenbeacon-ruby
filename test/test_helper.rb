require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'screenbeacon'
require 'test/unit'
require 'mocha/setup'
require 'stringio'
require 'shoulda'
require File.expand_path('../test_data', __FILE__)

# monkeypatch request methods
module Screenbeacon
  @mock_rest_client = nil

  def self.mock_rest_client=(mock_client)
    @mock_rest_client = mock_client
  end

  def self.execute_request(opts)
    get_params = (opts[:headers] || {})[:params]
    post_params = opts[:payload]
    case opts[:method]
    when :get then @mock_rest_client.get opts[:url], get_params, post_params
    when :post then @mock_rest_client.post opts[:url], get_params, post_params
    when :delete then @mock_rest_client.delete opts[:url], get_params, post_params
    end
  end
end

class Test::Unit::TestCase
  include Screenbeacon::TestData
  include Mocha

  setup do
    @mock = mock
    Screenbeacon.mock_rest_client = @mock
    Screenbeacon.api_id="foo"
    Screenbeacon.api_token="bar"
  end

  teardown do
    Screenbeacon.mock_rest_client = nil
    Screenbeacon.api_id=nil
    Screenbeacon.api_token=nil
  end
end
