require 'dm-core/type'

module DataMapper
  module Types
    class Discriminator < Type
      primitive Class
      default   lambda { |resource, property| resource.model }
      required  true

      # @api private
      def self.bind(property)
        repository_name = property.repository_name
        model           = property.model
        property_name   = property.name
        
        model.instance_variable_set(:@discriminator, property)

        model.class_eval <<-RUBY, __FILE__, __LINE__+1
          extend Chainable
          
          extendable do
            def inherited(model)
              super  # setup self.descendants
              model.default_scope(#{repository_name.inspect}).update(#{property_name.inspect} => model.descendants)
            end
            
            def discrimination(record)
              record[@discriminator]
            end
          end
        RUBY
      end
    end # class Discriminator
  end # module Types
end # module DataMapper
