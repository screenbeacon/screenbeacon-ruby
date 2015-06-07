require File.expand_path('../../test_helper', __FILE__)

module Screenbeacon
  class UtilTest < Test::Unit::TestCase
    should "symbolize_names should convert names to symbols" do
      start = {
        'foo' => 'bar',
        'array' => [{ 'foo' => 'bar' }],
        'nested' => {
          1 => 2,
          :symbol => 9,
          'string' => nil
        }
      }
      finish = {
        :foo => 'bar',
        :array => [{ :foo => 'bar' }],
        :nested => {
          1 => 2,
          :symbol => 9,
          :string => nil
        }
      }

      symbolized = Screenbeacon::Util.symbolize_names(start)
      assert_equal(finish, symbolized)
    end

    should "normalize_opts should reject nil keys" do
      assert_raise { Screenbeacon::Util.normalize_opts(nil) }
      assert_raise { Screenbeacon::Util.normalize_opts(:api_id => nil, :api_token => nil) }
    end
  end
end
