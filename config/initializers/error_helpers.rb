module ErrorHelpers
  def error_messages_for(*params)
    options = params.extract_options!.symbolize_keys
    
    if object = options.delete(:object)
      objects = [object].flatten
    else
      objects = params.collect { |object_name| instance_variable_get("@#{object_name}") }.compact
    end
    
    count = objects.inject(0) { |sum, object| sum + object.errors.count }
    
    unless count.zero?
      flash.now[:errors] = "There are errors in your form."
    end
  end
  
  def text_or_error_message_on(alternate_text, object, method, prepend_text = "", append_text = "", css_class = "formError")
    if (obj = (object.respond_to?(:errors) ? object : instance_variable_get("@#{object}"))) && errors = obj.errors.on(method)
      content_tag("div", "#{prepend_text}#{errors.is_a?(Array) ? errors.first : errors}#{append_text}", :class => css_class)
    else
      alternate_text
    end
  end
end

ActionView::Base.send(:include, ErrorHelpers)