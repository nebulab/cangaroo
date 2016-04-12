require 'logger'

module Cangaroo
  module Log

    def log
      Cangaroo::Log::Writer.instance
    end

    class Writer
      include Singleton

      attr_reader :default_tags

      def initialize
        @l = Logger.new(STDOUT)
        @default_tags = {}
      end

      def reset_context!
        @default_tags = {}
      end

      def set_context(job)
        reset_context!

        @default_tags.merge!({
          job: job.class.to_s,
          job_id: job.job_id,
          connection: job.class.connection
        })
      end

      def error(msg, opts={})
        @l.error("#{msg}: #{stringify_tags(opts)}")
      end

      def info(msg, opts={})
        @l.info("#{msg}: #{stringify_tags(opts)}")
      end

      def debug(msg, opts={})
        @l.debug("#{msg}: #{stringify_tags(opts)}")
      end

      def warn(msg, opts={})
        @l.warn("#{msg}: #{stringify_tags(opts)}")
      end

      private

        def stringify_tags(additional_tags)
          additional_tags = additional_tags.dup

          # TODO add support for cangaroo-specific metatags

          @default_tags.merge(additional_tags).map { |k,v| "#{k}=#{v}" }.join(' ')
        end

    end

  end
end
