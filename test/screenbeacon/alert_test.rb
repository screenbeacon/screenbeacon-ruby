require File.expand_path('../../test_helper', __FILE__)

module Screenbeacon
  class AlertTest < Test::Unit::TestCase
    should "alerts should be listable" do
      @mock.expects(:get).once.returns(test_response(test_alert_array))
      c = Screenbeacon::Alert.all
      assert c.kind_of? Array
      assert c[0].kind_of? Screenbeacon::Alert
    end

    should "alert should be deletable" do
      @mock.expects(:delete).once.returns(test_response(test_alert({:deleted => true})))
      c = Screenbeacon::Alert.new("test_alert")
      c.delete
      assert c.deleted
    end

    should "alerts should be updateable" do
      @mock.expects(:get).once.returns(test_response(test_alert({:name => "fubu"})))
      @mock.expects(:post).once.returns(test_response(test_alert({:name => "barbu"})))
      c = Screenbeacon::Alert.new("test_alert").refresh
      assert_equal "fubu", c.name
      c.name = "barbu"
      c.save
      assert_equal "barbu", c.name
    end

    should "create should return a new alert" do
      @mock.expects(:post).once.returns(test_response(test_alert))
      c = Screenbeacon::Alert.create
      assert_equal "Screenbeacon", c.name
    end

  end
end
