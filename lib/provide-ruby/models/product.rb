module Provide
  class Product < Model
    def resource_name
      'products'
    end
    
    def save
      self[:company_id] = '3'
      req = api_client.get(uri, company_id: self[:company_id], gtin: self[:gtin])
      response = req.code == 200 ? JSON.parse(req.response_body) : []
      merge!(response.first) if response.size == 1
      super
    end
  end
end
