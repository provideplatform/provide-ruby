module Provide
  class Customer < Model
    def resource_name
      'customers'
    end

    def save
      self[:company_id] = Provide.api_company_id
      req = api_client.get(uri, company_id: self[:company_id], customer_number: self[:customer_number])
      response = req.code == 200 ? JSON.parse(req.response_body) : []
      merge!(response.first) if response.size == 1
      super
    end
  end
end
