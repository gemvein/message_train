# MessageTrain
[![Build Status](https://travis-ci.org/gemvein/message_train.svg)](https://travis-ci.org/gemvein/message_train) 
[![Coverage Status](https://coveralls.io/repos/gemvein/message_train/badge.svg?branch=master&service=github)](https://coveralls.io/github/gemvein/message_train?branch=master) 
[![Gem Version](https://badge.fury.io/rb/message_train.svg)](http://badge.fury.io/rb/message_train)

MessageTrain is a Rails 4 and 5 Private Messaging Gem that uses bootstrap to send
and display private messages from one user to another. It can also be
configured to send messages to a user collective (such as a certain Role or
Group of users).

Messages can be saved as drafts instead of sending. Message composition
features type-ahead completion for recipients, wysiwyg html bodies, and an
arbitrary number of attachments. Messages are grouped together into
conversations, and allow valid senders to reply to a given message. Any given
conversation can be ignored if it is no longer of interest to the user, at
which point no further messages will be received in that conversation. The
'read' or 'unread' status of messages is tracked automatically, and can also
be changed manually by the user.

Conversations are grouped into various boxes, depending on their status for
that user: in, sent, all, drafts, trash, ignored. Any message can be trashed
by the user, at which point the user has the option to permanently delete it.

Email messages are sent when a user receives a message, either directly or
through a collective (unless they have unsubscribed from those notifications
or all notifications).

### Inbox Page
![Inbox Screenshot](http://gemvein.com/assets/screenshots/message_train-box-in.png)   

## Installation

First, install the gem:
    
```bash
gem 'ckeditor'
gem 'message_train'
```

Then, run the install generator:

```bash
rails g message_train:install
```

And then run `rake db:migrate`.

Next, add to your models, each of which will need some kind of display
name column and some kind of slug (could be the same). See below for the
options for this mixin:

```ruby
# in /app/models/user.rb
message_train

# OR to set the name and slug columns:

message_train slug_column: :short_name, name_column: :display_name
```

To include Message Train variables and helpers in your controllers, add
this concern to your controller or application controller:

```ruby
include MessageTrain::MessageTrainSupport
```

Add to your application.css.scss:

```scss
@import 'message_train';
```

And in your application.js:

```js
//= require message_train
```

In your layout, supposing you use haml:

```haml
#alert_area
  = alert_flash_messages
```

If you use bootstrap, you can use the built-in bootstrap sidebar menu
(makes use of bootstrap_leather, which is a dependency of this gem)

```haml
- if user_signed_in?
  = message_train_widget
= render_widgets 'md', 3
```

### Required helper methods

If you don't use devise with its `current_user` method, you will need to
configure MessageTrain to use whatever method you use:

```ruby
MessageTrain.configure do |config|
  config.current_user_method = :current_subscriber
end
```

### Mixin options

The `message_train` mixin takes the following options:

<dl>
<dt>only</dt>
<dd>A symbol or array of symbols to be the only relationships used, which can include: [:sender, :recipient]</dd>
<dt>except</dt>
<dd>A symbol or array of symbols not to create relationships for, which can include: [:sender, :recipient]</dd>
<dt>valid_senders</dt>
<dd>A method name to call for a list of valid senders for this model</dd>
<dt>collectives_for_recipient</dt>
<dd>A method that, when passed @box_user, will return a collection of valid instances of this model for that @box_user to receive. Probably a scope. (e.g. it might return groups that the user is a member of)</dd>
<dt>valid_recipients</dt>
<dd>A method that returns a collection of valid recipients for this model. default: nil</dd>
<dt>name_column</dt>
<dd>The column by which to name and find this model. default: :name</dd>
<dt>slug_column</dt>
<dd>The column with the short, typeable form of the name. default: :slug</dd>
</dl>

### Smaller address book

By default, the address book will contain all objects of the
current_user_method object's model type. To change this behavior, define
an address book method on your recipient models, something like this:

```ruby
def self.valid_recipients_for(user)
    # Supposing you use rolify
    with_role(:friend, user)
end
```

And in your model:

```ruby
message_train address_book_method: :valid_recipients_for
```

Or in your initializer:

```ruby
config.address_book_methods[:users] = :valid_recipients_for
```

## View Helpers

### Boxes
<dl>
<dt>boxes_dropdown_list</dt>
<dd>Bootstrap navigation dropdown list of boxes. (Be sure to check thatuser is signed in before calling, or you'll get errors.)</dd>
<dt>boxes_widget</dt>
<dd>Bootstrap widget with list of boxes</dd>
<dt>box_nav_item(box)</dt>
<dd>Bootstrap list item for one box</dd>
<dt>box_list_item(box)</dt>
<dd>Bootstrap list item for one box</dd>
<dt>box_participant_name(participant)</dt>
<dd>Name of the participant, according to the method specified in yourconfiguration or model.</dd>
<dt>box_participant_slug(participant)</dt>
<dd>Slug of the participant, according to the method specified in your configuration or model.</dd>
</dl>

### Conversations
<dl>
<dt>conversation_senders(conversation)</dt>
<dd>List of senders for a given conversation</dd>
<dt>conversation_class(box, conversation)</dt>
<dd>CSS class to put on a given conversation when in a certain box</dd>
<dt>conversation_trashed_toggle(conversation)</dt>
<dd>Link to toggle trashed status of a conversation</dd>
<dt>conversation_read_toggle(conversation)</dt>
<dd>Link to toggle read status of a conversation</dd>
<dt>conversation_ignored_toggle(conversation)</dt>
<dd>Link to toggle ignored status of a conversation</dd>
<dt>conversation_deleted_toggle(conversation)</dt>
<dd>Link to toggle deleted status of a conversation</dd>
<dt>conversation_toggle(conversation, icon, mark_to_set, method, title, options = {})</dt>
<dd>Link to toggle some status of a conversation</dd>
</dl>

### Messages
<dl>
<dt>message_class(box, message)</dt>
<dd>CSS class to put on a given message when in a certain box</dd>
<dt>message_trashed_toggle(message)</dt>
<dd>Link to toggle trashed status of a message</dd>
<dt>message_read_toggle(message)</dt>
<dd>Link to toggle read status of a message</dd>
<dt>message_deleted_toggle(message)</dt>
<dd>Link to toggle ignored status of a message</dd>
<dt>message_toggle(message, icon, mark_to_set, title, options = {})</dt>
<dd>Link to toggle some status of a message</dd>
<dt>message_recipients(message)</dt>
<dd>Recipients for a given message</dd>
</dl>

## Configuration

<dl>
<dt>config.slug_columns</dt>
<dd>Usually populated by options on the `message_train` mixin for models, this contains a `Hash` of tables and their slug columns</dd>
<dt>config.name_columns</dt>
<dd>Usually populated by options on the `message_train` mixin for models, this contains a `Hash` of tables and their name columns</dd>
<dt>config.user_model</dt>
<dd>Defaults to `'User'`</dd>
<dt>config.current_user_method</dt>
<dd>Defaults to `Devise`'s `current_user`</dd>
<dt>config.user_sign_in_path</dt>
<dd>Defaults to `Devise`'s `/users/sign_in`</dd>
<dt>config.user_route_authentication_method</dt>
<dd>Defaults to `Devise`'s `:user`</dd>
<dt>config.address_book_method</dt>
<dd>Default value if `address_book_methods` doesn't have a match for thistable</dd>
<dt>config.address_book_methods</dt>
<dd>`Hash` of tables and the methods those tables use to provide atab-completion address book for that table.</dd>
<dt>config.recipient_tables</dt>
<dd>Usually populated by options on the `message_train` mixin for models,this contains a `Hash` of tables and their class names</dd>
<dt>config.collectives_for_recipient_methods</dt>
<dd>Usually populated by options on the `message_train` mixin for models,this contains a list of collectives that act as recipients through which users receive messages.</dd>
<dt>config.valid_senders_methods</dt>
<dd>Usually populated by options on the `message_train` mixin for models,this contains a `Hash` of tables and the methods that indicate which users can send messages to a given instance from that table.</dd>
<dt>config.valid_recipients_methods</dt>
<dd>Usually populated by options on the `message_train` mixin for models,this contains a `Hash` of tables and the methods that indicate which users can receive messages from a given instance from that table.</dd>
<dt>config.from_email</dt>
<dd>The email address from which notification emails are sent.</dd>
<dt>config.site_name</dt>
<dd>The name of the site, for use in notification emails.</dd>
</dl>

## Upgrading

### 0.4.0

Version 0.4.0 introduced database changes to the foreign key columns to
work with Rails 4.2.5. Let me know if you need help migrating your app to
the newly named foreign keys.

### 0.3.0

A new config variable was added for the user model, which will be used to
generate a new user if the user is anonymous.

### 0.2.0
New columns were added with version 0.2.0, so when upgrading be sure to
install the latest migrations:

```bash
rake message_train:install:migrations
```

Running this command is harmless if the migrations are already installed,
they will simply be skipped.

## Contributing to MessageTrain

*   Check out the latest master to make sure the feature hasn't been
    implemented or the bug hasn't been fixed yet.
*   Check out the issue tracker to make sure someone already hasn't
    requested it and/or contributed it.
*   Fork the project.
*   Start a feature/bugfix branch.
*   Commit and push until you are happy with your contribution.
*   Make sure to add tests for it. This is important so I don't break it
    in a future version unintentionally.
*   Please try not to mess with the Rakefile, version, or history. If you
    want to have your own version, or is otherwise necessary, that is
    fine, but please isolate to its own commit so I can cherry-pick around
    it.

## Contributors
*   [Karen Lundgren](https://github.com/nerakdon)
*   [Chad Lundgren](https://github.com/chadlundgren)

## Copyright

Copyright (c) 2015-2017 Gem Vein. See LICENSE.txt for further details.
