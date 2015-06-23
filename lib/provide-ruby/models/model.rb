API_TOKEN = '00ec1b22-c244-4a63-8501-ab7c60273f57'
API_TOKEN_SECRET = 'b70592a5b0fef8a214922cacaed04835'
API_COMPANY_ID = '3'

module Provide
  class Model < HashWithIndifferentAccess
    class << self
      def find(id)
        model = self.new
        uri = model.uri
        model.api_client.get(uri, id: id)
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
      self[:company_id] ||= API_COMPANY_ID
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
