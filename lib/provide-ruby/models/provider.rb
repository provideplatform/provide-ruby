module Provide
  class Provider < Model
    def resource_name
      'providers'
    end

    def save
      self[:company_id] = '3'
      req = api_client.get(uri, company_id: self[:company_id])
      response = req.code == 200 ? JSON.parse(req.response_body) : []
      
      response.each do |provider| # FIXME -- this is a nasty hack and we need to be getting a unique identifier for each provider in the MFRM data feed
        if provider['contact']['name'].downcase == self[:contact][:name].downcase
          self[:id] = provider['id']
          break
        end
      end

      super
    end
  end
end
