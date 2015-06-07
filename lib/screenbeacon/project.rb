module Screenbeacon
  class Project < APIResource
    include Screenbeacon::APIOperations::Create
    include Screenbeacon::APIOperations::Update
    include Screenbeacon::APIOperations::Delete
    include Screenbeacon::APIOperations::List

    def alerts
      Alert.all({ :project_id => id }, @opts)
    end

    def resolve_all(opts={})
      response, opts = request(:patch, resolve_url, {}, opts)
      refresh_from(response, opts)
    end

    private

    def resolve_all_url
      url + '/resolve_all'
    end

  end
end
