module MessageTrain
  # Application mailer
  class ApplicationMailer < ActionMailer::Base
    default(
      from: MessageTrain.configuration.from_email,
      charset: 'utf-8',
      content_type: 'text/html'
    )
    layout 'mailer'
  end
end
