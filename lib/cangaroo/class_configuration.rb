module Cangaroo
  module ClassConfiguration
    extend ActiveSupport::Concern

    module ClassMethods
      def class_configuration(key, default = nil)
        class_attribute :"_#{key}"

        define_singleton_method(key) do |*args|
          if args.empty?
            return self.send(:"_#{key}") || default
          end

          self.send(:"_#{key}=", args.first)
        end

        define_method(key) do
          self.send(:"_#{key}") || default
        end
      end
    end

  end
end
