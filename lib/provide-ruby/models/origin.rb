module Provide
  class Origin < Model
    class << self
      def find(market_id, id)
        model = self.new
        model[:market_id] = market_id
        uri = model.uri
        req = id ? model.api_client.get("#{model.resource_name}/#{id}") : model.api_client.get(model.resource_name)
        response = JSON.parse(req.response_body)
        response = response[0] if response.is_a?(Array) && response.size == 1
        model.merge!(response) if req.code == 200
        model
      end
    end
    
    def resource_name
      "markets/#{market_id}/origins"
    end

    def market_id
      self[:market_id]
    end

    def save
      req = api_client.get(uri, warehouse_number: self[:warehouse_number])
      response = req.code == 200 ? JSON.parse(req.response_body) : []
      merge!(response.first) if response.size == 1
      super
    end
  end
end
