module Provide
  class Model < HashWithIndifferentAccess
    class << self
      def find(id)
        model = self.new
        uri = model.uri
        req = uri.split(/\//i).size == 1 ? model.api_client.get("#{uri}/#{id}") : model.api_client.get(uri, id: id)
        response = JSON.parse(req.response_body)
        response = response[0] if response.is_a?(Array) && response.size == 1
        model.merge!(response) if req.code == 200
        model
      end
      
      def where(params)
        model = self.new
        model.api_client.get("#{model.uri}", params)
      end
    end

    def api_client
      @api_client ||= begin
        ApiClient.new(API_TOKEN, API_TOKEN_SECRET)
      end
    end

    def delete
      return unless self[:id]
      api_client.delete("#{uri}/#{self[:id]}")
    end

    def query
      api_client.get(uri)
    end

    def resource_name
      nil
    end

    def save
      self[:company_id] ||= API_COMPANY_ID if API_COMPANY_ID
      if self[:id]
        req = api_client.put("#{uri}/#{self[:id]}", self)
      else
        req = api_client.post(uri, self)
        merge!(JSON.parse(req.response_body)) if req.code == 201
      end
      req
    end

    def uri
      "#{resource_name.to_s}"
    end
  end
end
