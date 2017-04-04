module Cangaroo
  module ClassConfiguration
    extend ActiveSupport::Concern

    # NOTE you must use the `_key` class attribute to nil out a class_cofiguration

    module ClassMethods
      def class_configuration(key, default = nil)
        class_attribute :"_#{key}"

        define_singleton_method(key) do |*args|
          if args.empty?
            value = send(:"_#{key}")

            return value.nil? ? default : value
          end

          send(:"_#{key}=", args.first)
        end

        define_method(key) do
          self.class.send(key)
        end
      end
    end
  end
end
