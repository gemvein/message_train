# MessageTrain authorization
module MessageTrainAuthorization
  extend ActiveSupport::Concern

  protected

  def authorize_collective(collective, division)
    return false unless authorize_collective_access(collective)
    case division
    when :in, :ignored
      authorize_collective_receiving(collective)
    when :sent, :drafts
      authorize_collective_sending(collective)
    end
  end

  def authorize_collective_access(collective)
    return true if collective.allows_access_by? @box_user
    flash[:error] = :access_to_that_box_denied.l
    redirect_to main_app.root_url
    false
  end

  def authorize_collective_receiving(collective)
    return true if collective.allows_receiving_by? @box_user
    flash[:error] = :access_to_that_box_denied.l
    redirect_to message_train.collective_box_url(collective.path_part, :sent)
    false
  end

  def authorize_collective_sending(collective)
    return true if collective.allows_sending_by? @box_user
    flash[:error] = :access_to_that_box_denied.l
    redirect_to message_train.collective_box_url(collective.path_part, :in)
    false
  end
end
