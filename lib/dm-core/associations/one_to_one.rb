module DataMapper
  module Associations
    module OneToOne #:nodoc:
      class Relationship < Associations::Relationship
        %w[ public protected private ].map do |visibility|
          superclass.send("#{visibility}_instance_methods", false).each do |method|
            undef_method method unless method.to_s == 'initialize'
          end

          # remove mixed in methods
          undef_method *DataMapper::Subject.send("#{visibility}_instance_methods", false)
        end

        # Loads (if necessary) and returns association target
        # for given source
        #
        # @api semipublic
        def get(source, other_query = nil)
          unless loaded?(source) || valid_source?(source)
            set(source, default_for(source))
          end

          relationship.get(source, other_query).first
        end

        # Sets and returns association target
        # for given source
        #
        # @api semipublic
        def set(source, target)
          relationship.set(source, [ target ].compact).first
        end

        # @api semipublic
        def default_for(source)
          relationship.default_for(source).first
        end

        # @api public
        def kind_of?(klass)
          super || relationship.kind_of?(klass)
        end

        # @api public
        def instance_of?(klass)
          super || relationship.instance_of?(klass)
        end

        # @api public
        def respond_to?(method, include_private = false)
          super || relationship.respond_to?(method, include_private)
        end

        private

        attr_reader :relationship

        # Initializes the relationship. Always assumes target model class is
        # a camel cased association name.
        #
        # @api semipublic
        def initialize(name, target_model, source_model, options = {})
          klass = options.key?(:through) ? ManyToMany::Relationship : OneToMany::Relationship
          target_model ||= ActiveSupport::Inflector.camelize(name).freeze
          @relationship = klass.new(name, target_model, source_model, options)
        end

        # @api private
        def method_missing(method, *args, &block)
          relationship.send(method, *args, &block)
        end
      end # class Relationship
    end # module HasOne
  end # module Associations
end # module DataMapper
