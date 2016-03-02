json.message @box.message
unless @box.results.all.empty?
  json.results @box.results.all do |item|
    json.css_id item[:css_id]
    json.path item[:path]
    json.message item[:message]
  end
end
