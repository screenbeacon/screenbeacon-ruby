module Screenbeacon
  module TestData
    def test_response(body, code=200)
      # When an exception is raised, restclient clobbers method_missing.  Hence we
      # can't just use the stubs interface.
      body = JSON.generate(body) if !(body.kind_of? String)
      m = mock
      m.instance_variable_set('@screenbeacon_values', { :body => body, :code => code })
      def m.body; @screenbeacon_values[:body]; end
      def m.code; @screenbeacon_values[:code]; end
      m
    end

    def test_project(params={})
      {
        :id => 13,
        :name => "Screenbeacon",
        :created_at => "2015-01-15T06:32:24Z",
        :updated_at =>"2015-06-06T23:35:33Z",
        :image_url => "https://screenbeacon.s3.amazonaws.com/projects/project/13/thumb_avatar_2x.png",
        :active_alerts_count => 1,
        :owner_avatar_url => "https://screenbeacon.s3.amazonaws.com/uploads/user/avatar/2/retina_jordan-humphreys.jpg",
        :position => 0,
        :tests_count => 2
      }.merge(params)
    end

    def test_project_array
      [test_project, test_project, test_project]
    end

    def test_test(params={})
      {
        :id => 3,
        :name => "Amazon Test 2",
        :description => "Testing broken images.",
        :project_id => 14,
        :state => "failed",
        :last_run_at => "2015-06-06T23:33:58Z",
        :active_alert => test_alert({:project => test_project, :test_version => test_version}),
        :source => nil,
        :md5 => "70c584f3b0ddba3f7e70663ed8cc61ff",
        :times_run => 447,
        :estimated_next_run_at => nil,
        :steps => [test_step, test_step, test_step],
        :created_at => "2015-01-17T03:41:32Z",
        :updated_at => "2015-01-17T03:41:32Z"
      }.merge(params)
    end

    def test_test_array
      [test_test, test_test, test_test]
    end

    def test_alert(params={})
      {
        :id => 489,
        :resolved_at => "2015-01-26T06:31:53Z",
        :resolved_by_user_id => 2,
        :baseline_image_url => "https://screenbeacon.s3.amazonaws.com/captures/alert/489/baseline_image.png?",
        :diff_image_url => "https://screenbeacon.s3.amazonaws.com/comparisons/alert/489/diff_image.gif?",
        :failed_at => "2015-01-16T03:13:25Z",
        :resolved => true,
        :failure_image_url => "https://screenbeacon.s3.amazonaws.com/captures/alert/489/failure_image.png",
        :project_id => 14,
        :message => "Unable to find element",
        :completed => false,
        :success => false,
        :state => "resolved",
        :step => nil,
        :created_at => "2015-01-16T03:13:25Z",
        :updated_at => "2015-01-26T06:31:53Z",
        :times_seen_count => 1,
        :passing => false,
        :failing => false,
        :error => false,
        :test_id => 2,
        :thumb_url => "https://screenbeacon.s3.amazonaws.com/captures/alert/489/thumb_baseline_image.png?",
        :screenshot => true
      }
    end

    def test_alert_array
      [test_alert, test_alert, test_alert]
    end

    def test_step(params={})
      {
        :id => 14,
        :position => 0,
        :command => "width 1280",
        :completed => true,
        :success => true,
        :message => nil,
        :screenshot => false,
        :created_at => "2015-01-17T03:41:32Z",
        :updated_at => "2015-01-17T04:32:54Z",
        :baseline_img_url => "https://captures-screenbeacon.s3.amazonaws.com/70c584f3b0ddba3f7e70663ed8cc61ff/baselines/0_screen.png?1433638217",
        :diff_img_url => "https://captures-screenbeacon.s3.amazonaws.com/70c584f3b0ddba3f7e70663ed8cc61ff/diffs/0_screen.png?1433638217",
        :failure_img_url => "https://captures-screenbeacon.s3.amazonaws.com/70c584f3b0ddba3f7e70663ed8cc61ff/failures/0_screen.png?1433638217",
        :state => "passing"
      }
    end

    def test_step_array
      [test_step, test_step, test_step]
    end

    def test_version(params={})
      {
        :id => 3,
        :test_id => 3,
        :created_at => "2015-01-16T19:41:32.615-08:00",
        :updated_at => "2015-06-06T16:33:57.256-07:00",
        :last_run_at => "2015-06-06T16:33:58.000-07:00",
        :times_run => 447,
        :state => "failing",
        :source => nil,
        :last_enqueued_at => nil
      }
    end

    def test_version_array
      [test_version, test_version, test_version]
    end

    def test_invalid_api_id_error
      {
        :error => {
          :type => "invalid_request_error",
          :message => "Invalid API ID provided: invalid"
        }
      }
    end

    def test_missing_id_error
      {
        :error => {
          :param => "id",
          :type => "invalid_request_error",
          :message => "Missing id"
        }
      }
    end

  end
end
