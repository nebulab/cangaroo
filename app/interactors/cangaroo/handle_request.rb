module Cangaroo
  class HandleRequest
    include Interactor::Organizer

    organize AuthenticateConnection,
             PerformFlow
  end
end
