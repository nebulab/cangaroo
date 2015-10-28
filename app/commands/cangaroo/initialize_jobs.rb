module Cangaroo
  class InitializeJobs
    prepend SimpleCommand

    def initialize(item)
      @item = item
    end

    def call
      Rails.application.config.cangaroo.jobs.map { |klass| klass.new(@item) }
    end
  end
end
