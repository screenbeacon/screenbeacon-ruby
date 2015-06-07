# -*- coding: utf-8 -*-
require File.expand_path('../../test_helper', __FILE__)

module Screenbeacon
  class ApiResourceTest < ::Test::Unit::TestCase
    should "creating a new APIResource should not fetch over the network" do
      @mock.expects(:get).never
      Screenbeacon::Project.new("someid")
    end

    should "creating a new APIResource from a hash should not fetch over the network" do
      @mock.expects(:get).never
      Screenbeacon::Project.construct_from({
        :id => "somecustomer",
        :object => "customer"
      })
    end

    should "setting an attribute should not cause a network request" do
      @mock.expects(:get).never
      @mock.expects(:post).never
      c = Screenbeacon::Project.new("test_project");
      c.card = {:id => "somecard", :object => "card"}
    end

    should "accessing id should not issue a fetch" do
      @mock.expects(:get).never
      c = Screenbeacon::Project.new("test_project")
      c.id
    end

    should "not specifying api credentials should raise an exception" do
      Screenbeacon.api_id = nil
      Screenbeacon.api_token = nil
      assert_raises Screenbeacon::AuthenticationError do
        Screenbeacon::Project.new("test_project").refresh
      end
    end

    should "using a nil api key should raise an exception" do
      assert_raises TypeError do
        Screenbeacon::Project.all({}, nil)
      end
      assert_raises TypeError do
        Screenbeacon::Project.all({}, { :api_id => nil, :api_token => nil })
      end
    end

    should "specifying api credentials containing whitespace should raise an exception" do
      Screenbeacon.api_id = "id "
      Screenbeacon.api_token = " token"
      assert_raises Screenbeacon::AuthenticationError do
        Screenbeacon::Project.new("test_project").refresh
      end
    end

    should "specifying invalid api credentials should raise an exception" do
      Screenbeacon.api_id = "invalid"
      Screenbeacon.api_token = "token"
      response = test_response(test_invalid_api_id_error, 401)
      assert_raises Screenbeacon::AuthenticationError do
        @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 401))
        Screenbeacon::Project.retrieve("failing_project")
      end
    end

    should "AuthenticationErrors should have an http status, http body, and JSON body" do
      Screenbeacon.api_id = "invalid"
      Screenbeacon.api_token = "token"
      response = test_response(test_invalid_api_id_error, 401)
      begin
        @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 401))
        Screenbeacon::Project.retrieve("failing_project")
      rescue Screenbeacon::AuthenticationError => e
        assert_equal(401, e.http_status)
        assert_equal(true, !!e.http_body)
        assert_equal(true, !!e.json_body[:error])
        assert_equal(test_invalid_api_id_error[:error], e.json_body[:error])
      end
    end
  end
end
