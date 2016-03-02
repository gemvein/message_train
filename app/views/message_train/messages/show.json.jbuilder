json.id @message.id
json.html render(
  partial: 'message',
  formats: [:html],
  locals: { message: @message }
)
