def path_to_url(path)
  "#{request.protocol}#{request.host_with_port.sub(/:80$/, '')}/"\
    "#{path.sub(%r{^/}, '')}"
end

def show_page
  save_page Rails.root.join('public', 'capybara.html')
  `launchy http://localhost:3000/capybara.html`
end

def submit_via_button(button_name)
  click_button button_name
end

def fill_in_autocomplete(field, options = {})
  field = find_field_by_label(field)
  fill_in field, with: options[:with]

  # The Stimulus controller debounces the search and populates a <datalist>
  # with the matching participant slugs; resolve to the first suggestion
  # rather than submitting the raw partial query as the recipient. Some
  # callers intentionally use a query with no real match (e.g. to leave
  # recipients unresolved for a draft), so don't wait/fail if none appear.
  list_id = find_field(field)[:list]
  return unless page.has_css?("##{list_id} option", visible: :all, wait: 1)

  suggestion = find("##{list_id} option", visible: :all)
  fill_in field, with: suggestion[:value]
end

# Cuprite drives the app on a real server thread with its own DB
# connection, so any marking it does through the browser commits outside
# the spec's transaction and would otherwise leak into later examples
# that reuse the same fixture conversation. Undo it the same way: on a
# separate thread, so this write also commits immediately instead of
# being rolled back with the rest of this example's (this thread's)
# transaction. SQLite only allows one writer at a time, and the RSpec
# thread's still-open transaction can be holding that lock at any given
# moment, so retry a few times rather than racing it.
def on_separate_connection(retries: 15)
  Thread.new do
    ActiveRecord::Base.connection_pool.with_connection do
      begin
        yield
      rescue ActiveRecord::StatementInvalid => e
        raise unless e.cause.is_a?(SQLite3::BusyException) && retries.positive?

        sleep 0.3
        retries -= 1
        retry
      end
    end
  end.join
end

def undo_leaked_mark(mark_to_set, conversation: unread_conversation)
  on_separate_connection do
    box = first_user.box(:in)
    # Ignore/unignore isn't a Receipt "marked_*" column like the other
    # marks - it's tracked on its own model, routed through here rather
    # than Box#mark (matching how BoxesController#destroy dispatches it).
    if %i[ignore unignore].include?(mark_to_set)
      MessageTrain::Ignore.send(mark_to_set, conversation, box)
    else
      box.mark(mark_to_set, conversations: conversation)
    end
  end
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
