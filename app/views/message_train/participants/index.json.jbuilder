json.participants @participants do |participant|
  json.partial! partial: 'participant', locals: { participant: participant }
end
