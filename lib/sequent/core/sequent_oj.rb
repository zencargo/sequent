require 'oj'

module Sequent
  module Core
    # small wrapper class to centralize oj and its settings.
    class Oj
      ::Oj.default_options = {
        bigdecimal_as_decimal: false,
        mode: :compat,
        use_as_json: true
      }

      def self.strict_load(json)
        ::Oj.strict_load(json, {})
        # JSON.parse(json)
      end

      def self.dump(obj)
        ::Oj.dump(obj)
        # JSON.dump(obj)
      end
    end
  end
end
