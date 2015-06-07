module Screenbeacon
  class Project < APIResource
    include Screenbeacon::APIOperations::Create
    include Screenbeacon::APIOperations::Update
    include Screenbeacon::APIOperations::Delete
    include Screenbeacon::APIOperations::List


    def alerts
      Alert.all({ :project_id => id }, @opts)
    end
  end
end
