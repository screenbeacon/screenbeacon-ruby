module Screenbeacon
  class Alert < APIResource
    include Screenbeacon::APIOperations::List

    def resolve(opts={})
      response, opts = request(:patch, resolve_url, {}, opts)
      refresh_from(response, opts)
    end

    # Resolve all alerts on account
    def self.resolve_all(opts={})
      response, opts = request(:post, resolve_all_url, {}, opts)
      refresh_from(response, opts)
    end

    def self.resolve_all(filters={}, opts={})
      response, opts = request(:post, resolve_all_url, filters, opts)
      Util.convert_to_screenbeacon_object(response, opts)
    end

    private

    def resolve_url
      url + '/resolve'
    end

    def self.resolve_all_url
      url + '/resolve'
    end

  end
end
