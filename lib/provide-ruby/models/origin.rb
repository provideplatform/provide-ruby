module Provide
  class Origin < Model
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
