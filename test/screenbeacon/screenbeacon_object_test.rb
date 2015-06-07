require File.expand_path('../../test_helper', __FILE__)

module Screenbeacon
  class ScreenbeaconObjectTest < Test::Unit::TestCase
    should "implement #respond_to correctly" do
      obj = Screenbeacon::ScreenbeaconObject.construct_from({ :id => 1, :foo => 'bar' })
      assert obj.respond_to?(:id)
      assert obj.respond_to?(:foo)
      assert !obj.respond_to?(:baz)
    end

    should "marshal a screenbeacon object correctly" do
      obj = Screenbeacon::ScreenbeaconObject.construct_from({ :id => 1, :name => 'Screenbeacon' }, {:api_id => 'apiid', :api_token => 'apitoken'})
      m = Marshal.load(Marshal.dump(obj))
      assert_equal 1, m.id
      assert_equal 'Screenbeacon', m.name
      expected_hash = {:api_id => 'apiid', :api_token => 'apitoken'}
      assert_equal expected_hash, m.instance_variable_get('@opts')
    end

    should "recursively call to_hash on its values" do
      nested = Screenbeacon::ScreenbeaconObject.construct_from({ :id => 7, :foo => 'bar' })
      obj = Screenbeacon::ScreenbeaconObject.construct_from({ :id => 1, :nested => nested })
      expected_hash = { :id => 1, :nested => { :id => 7, :foo => 'bar' } }
      assert_equal expected_hash, obj.to_hash
    end
  end
end
