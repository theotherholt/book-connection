require 'ipaddr'

module ExceptionNotifiable
  def self.included(target)
    target.extend(ClassMethods)
  end
  
  module ClassMethods
    def consider_local(*args)
      local_addresses.concat(args.flatten.map { |a| IPAddr.new(a) })
    end
    
    def local_addresses
      addresses = read_inheritable_attribute(:local_addresses)
      unless addresses
        addresses = [IPAddr.new("127.0.0.1")]
        write_inheritable_attribute(:local_addresses, addresses)
      end
      addresses
    end
    
    def exception_data(deliverer=self)
      if deliverer == self
        read_inheritable_attribute(:exception_data)
      else
        write_inheritable_attribute(:exception_data, deliverer)
      end
    end
    
    def exceptions_to_treat_as_404
      exceptions = [
        ActiveRecord::RecordNotFound,
        ActionController::UnknownController,
        ActionController::UnknownAction
      ]
      
      exceptions << ActionController::RoutingError if ActionController.const_defined?(:RoutingError)
      exceptions
    end
  end
  
  #--
  # Private Methods
  #++
  private
  
  def local_request?
    remote = IPAddr.new(request.remote_ip)
    !self.class.local_addresses.detect { |addr| addr.include?(remote) }.nil?
  end
  
  def render_404
    render(:template => "main/404", :layout => 'application', :status => 404)
  end
  
  def render_500
    render(:template => "main/500", :layout => 'application', :status => 500)
  end
  
  def rescue_action_in_public(exception)
    case exception
      when *self.class.exceptions_to_treat_as_404
        render_404
      else
        render_500
        
        deliverer = self.class.exception_data
        data = case deliverer
          when nil then {}
          when Symbol then send(deliverer)
          when Proc then deliverer.call(self)
        end
        
        ExceptionNotifier.deliver_exception_notification(exception, self, request, data)
    end
  end
end