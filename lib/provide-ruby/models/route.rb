module Provide
  class Route < Model
    def resource_name
      'routes'
    end
  end
  
  def save
    req = api_client.get(uri, provider_origin_assignment_id: self[:provider_origin_assignment_id], identifier: self[:identifier])
    response = req.code == 200 ? JSON.parse(req.response_body) : []
    merge!(response.first) if response.size == 1
    super
  end
end
