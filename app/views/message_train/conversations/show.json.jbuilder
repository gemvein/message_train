json.id @conversation.id
json.html render(
  partial: 'conversation',
  formats: [:html],
  locals: { conversation: @conversation }
)
