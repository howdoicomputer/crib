module Crib
  # Contains useful helpers
  module Helpers
    # Constructs a REST URI
    #
    # @param args [String, Integer] objects to join together
    # @return [String]
    def self.construct_uri(*args)
      args.flatten.compact.map(&:to_s).reject(&:empty?).join('/')
    end
  end
end
