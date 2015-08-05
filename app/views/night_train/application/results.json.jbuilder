json.message @box.message
json.results @box.results do |item|
  key, result = item
  json.css_id key
  json.dump result.inspect
  json.path night_train.box_conversation_path(@box.division, result[:id])
  json.message result[:message]
end