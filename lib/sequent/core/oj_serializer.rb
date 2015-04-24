require 'oj'

::Oj.default_options={mode: :compat}

module Sequent
  module Core
    class OjSerializer
      def serialize(event)
        ::Oj.dump(event.attributes)
      end

      def deserialize(event_json)
        ::Oj.strict_load(event_json, {})
      end
    end
  end
end
