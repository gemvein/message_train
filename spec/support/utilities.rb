def path_to_url(path)
  "#{request.protocol}#{request.host_with_port.sub(/:80$/, '')}/"\
    "#{path.sub(%r{^/}, '')}"
end

def show_page
  save_page Rails.root.join('public', 'capybara.html')
  `launchy http://localhost:3000/capybara.html`
end

def submit_via_button(button_name)
  button_id = find("input[type=submit][value='#{button_name}']")[:id]
  page.execute_script("$('##{button_id}').click();")
end

# Used to fill ckeditor fields
# @param [String] locator label text for the textarea or textarea id
def fill_in_ckeditor(locator, options)
  locator = find_field_by_label(locator)
  # Fill the editor content
  page.execute_script <<-SCRIPT
      var ckeditor = CKEDITOR.instances.#{locator}
      ckeditor.setData('#{ActionController::Base.helpers.j options[:with]}')
      ckeditor.focus()
      ckeditor.updateElement()
  SCRIPT
end

def fill_in_autocomplete(field, options = {})
  field = find_field_by_label(field)
  fill_in field, with: options[:with]

  page.execute_script "$('##{field}').trigger('focus')"
  page.execute_script "$('##{field}').trigger('keydown')"

  return unless page.has_selector?('.tt-menu .tt-suggestion')
  selector = ".tt-menu .tt-suggestion:contains('#{options[:with]}')"
  page.execute_script '$("' + selector + '").trigger("mouseenter").click()'
end

def find_field_by_label(locator)
  if page.has_css?('label', text: locator)
    find('label', text: locator)[:for]
  else
    locator
  end
end

def wait_until(delay = 1)
  seconds_waited = 0
  while !yield && seconds_waited < Capybara.default_max_wait_time
    sleep delay
    seconds_waited += 1
  end
  yield && return
  puts "Waited for #{Capybara.default_max_wait_time} seconds."
  puts "{ #{yield} } did not become true, continuing."
end
