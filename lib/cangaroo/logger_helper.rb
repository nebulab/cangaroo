require 'active_support/concern'

module Cangaroo
  module LoggerHelper
    extend ActiveSupport::Concern

    def job_tags(tags = {})
      tags.merge!(job: self.class.to_s,
                  job_id: job_id,
                  connection: self.class.connection.to_s)
    end
  end
end
