require File.expand_path('../../test_helper', __FILE__)

module Screenbeacon
  class ProjectTest < Test::Unit::TestCase
    should "projects should be listable" do
      @mock.expects(:get).once.returns(test_response(test_project_array))
      c = Screenbeacon::Project.all
      assert c.kind_of? Array
      assert c[0].kind_of? Screenbeacon::Project
    end

    should "project should be deletable" do
      @mock.expects(:delete).once.returns(test_response(test_project({:deleted => true})))
      c = Screenbeacon::Project.new("test_project")
      c.delete
      assert c.deleted
    end

    should "projects should be updateable" do
      @mock.expects(:get).once.returns(test_response(test_project({:name => "fubu"})))
      @mock.expects(:post).once.returns(test_response(test_project({:name => "barbu"})))
      c = Screenbeacon::Project.new("test_project").refresh
      assert_equal "fubu", c.name
      c.name = "barbu"
      c.save
      assert_equal "barbu", c.name
    end

    should "create should return a new project" do
      @mock.expects(:post).once.returns(test_response(test_project))
      c = Screenbeacon::Project.create
      assert_equal "Screenbeacon", c.name
    end

  end
end
