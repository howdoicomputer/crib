module Crib
  # Contains useful helpers
  #
  # @api private
  module Helpers
    # Constructs a REST-friendly path
    #
    # @param args [String, Integer] objects to join together
    # @return [String] constructed path
    # @example Construct a simple REST-friendly path
    #   Helpers.construct_path('ping', 10)
    #    # => "ping/10"
    def self.construct_path(*args)
      args.flatten.compact.map(&:to_s).reject(&:empty?).join('/')
    end

    # Handles inheritable attributes in Classes
    module InheritableAttribute
      # Defines an attribute on a Class as inheritable
      #
      # @param name [Symbol] attribute name
      # @example Define an attribute as inheritable
      #   class Resource
      #     extend Crib::Helpers::InheritableAttribute
      #     inheritable_attr :_api
      #   end
      def inheritable_attr(name)
        instance_eval <<-EVAL
          def #{name}=(v); @#{name} = v; end
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
