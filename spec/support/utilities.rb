def path_to_url(path)
  "#{request.protocol}#{request.host_with_port.sub(/:80$/,"")}/#{path.sub(/^\//,"")}"
end

def show_page
  save_page Rails.root.join( 'public', 'capybara.html' )
  %x(launchy http://localhost:3000/capybara.html)
end