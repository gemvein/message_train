module MessageTrain
  # Application controller
  class ApplicationController < ::ApplicationController
    include MessageTrainSupport
    include MessageTrainAuthorization
  end
end
