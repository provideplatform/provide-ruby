module Provide
  class Market < Model
    def resource_name
      'markets'
    end

    def save
      merge!(response.first) if response.size == 1
      super
    end
  end
end
