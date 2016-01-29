module Provide
  class Lead < Model
    def resource_name
      'leads'
    end
    
    def uri
      "#{resource_name.to_s}"
    end
  end
end
