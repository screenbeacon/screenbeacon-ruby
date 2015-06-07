module Screenbeacon
  class Test < APIResource
    include Screenbeacon::APIOperations::Create
    include Screenbeacon::APIOperations::Update
    include Screenbeacon::APIOperations::Delete
    include Screenbeacon::APIOperations::List

    def run(opts={})
      response, opts = request(:patch, run_url, {}, opts)
      refresh_from(response, opts)
    end

    def pause(opts={})
      response, opts = request(:patch, pause_url, {}, opts)
      refresh_from(response, opts)
    end

    private

    def run_url
      url + '/run'
    end

    def pause_url
      url + '/pause'
    end

  end
end
