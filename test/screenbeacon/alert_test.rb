require File.expand_path('../../test_helper', __FILE__)

module Screenbeacon
  class AlertTest < ::Test::Unit::TestCase
    should "alerts should be listable" do
      @mock.expects(:get).once.returns(test_response(test_alert_array))
      c = Screenbeacon::Alert.all
      assert c.kind_of? Array
      # TODO: Should be a Screenbeacon::Alert
      assert c[0].kind_of? Screenbeacon::ScreenbeaconObject
    end

  end
end
