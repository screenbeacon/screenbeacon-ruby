require File.expand_path('../../test_helper', __FILE__)

module Screenbeacon
  class TestTest < Test::Unit::TestCase
    should "tests should be listable" do
      @mock.expects(:get).once.returns(test_response(test_test_array))
      c = Screenbeacon::Test.all
      assert c.kind_of? Array
      assert c[0].kind_of? Screenbeacon::Test
    end

    should "test should be deletable" do
      @mock.expects(:delete).once.returns(test_response(test_test({:deleted => true})))
      c = Screenbeacon::Test.new("test_test")
      c.delete
      assert c.deleted
    end

    should "tests should be updateable" do
      @mock.expects(:get).once.returns(test_response(test_test({:name => "fubu"})))
      @mock.expects(:post).once.returns(test_response(test_test({:name => "barbu"})))
      c = Screenbeacon::Test.new("test_test").refresh
      assert_equal "fubu", c.name
      c.name = "barbu"
      c.save
      assert_equal "barbu", c.name
    end

    should "create should return a new test" do
      @mock.expects(:post).once.returns(test_response(test_test))
      c = Screenbeacon::Test.create
      assert_equal "Screenbeacon", c.name
    end

  end
end
