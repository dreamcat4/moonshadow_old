
class Rack < Moonshadow::Manifest
  recipe :rack_stack
  
  def rack_stack
    require "web/manifest"
    Web::recipe :apache_stack
    
    
    
  end
end

