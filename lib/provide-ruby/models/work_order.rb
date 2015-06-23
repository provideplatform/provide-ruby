module Provide
  class WorkOrder < Model
    def resource_name
      'work_orders'
    end
  end
  
  def save
    super
  end
end
