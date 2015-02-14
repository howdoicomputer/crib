module Crib
  # Contains useful helpers
  # @api private
  module Helpers
    # Constructs a REST URI
    #
    # @param args [String, Integer] objects to join together
    # @return [String]
    def self.construct_uri(*args)
      args.flatten.compact.map(&:to_s).reject(&:empty?).join('/')
    end

    # Handles inheritable attributes in classes
    module InheritableAttribute
      # Defines an attribute on a class as inheritable
      #
      # @param name [Symbol] name of attribute to define as inheritable
      def inheritable_attr(name)
        instance_eval <<-EVAL
          def #{name}=(v)
            @#{name} = v
          end

          def #{name}
            @#{name} ||= InheritableAttribute.inherit(self, :#{name})
          end
        EVAL
      end

      private

      def self.inherit(klass, name)
        return unless klass.superclass.respond_to?(name) &&
                      value = klass.superclass.send(name)
        value.clone
      end
    end
  end
end
