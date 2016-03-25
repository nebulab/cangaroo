module Cangaroo
  class PerformFlow
    include Interactor::Organizer

    organize ValidateJsonSchema,
             CountJsonObject,
             PerformJobs
  end
end
