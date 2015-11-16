module Cangaroo
  class HandleRequest
    include Interactor::Organizer

    organize Cangaroo::AuthenticateConnection,
             Cangaroo::ValidateJsonSchema,
             Cangaroo::CountJsonObject,
             Cangaroo::PerformJobs
  end
end
