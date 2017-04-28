require 'rails_helper'

describe MessageTrain::BoxesHelper do
  include_context 'loaded site'
  include ControllerMacros

  before do
    view.extend BootstrapLeather::ApplicationHelper
    login_user first_user
  end

  context '#box_nav_item' do
    subject { helper.box_nav_item(first_user.box(:in)) }
    it { should have_tag 'li', text: /Inbox/ }
    it { should have_tag 'span', text: /[0-9]+/, with: { class: 'badge' } }
  end

  context '#box_list_item' do
    subject { helper.box_list_item(first_user.box(:in), class: 'foo') }
    it { should have_tag 'li', text: /Inbox/, with: { class: 'foo' } }
    it { should have_tag 'span', text: /[0-9]+/, with: { class: 'badge' } }
  end

  context '#boxes_widget' do
    subject { helper.boxes_widget(first_user) }
    it { should have_tag 'h3', text: /Messages/ }
    it { should have_tag 'ul', with: { class: 'list-group' } }
    it { should have_tag 'li', with: { class: 'list-group-item' }, count: 6 }
  end

  describe '#boxes_dropdown_list' do
    subject { helper.boxes_dropdown_list(first_user) }
    it { should have_tag 'ul', with: { class: 'dropdown-menu' }, count: 1 }
    it { should have_tag 'li', text: /^Inbox/ }
    it { should have_tag 'li', text: /^Sent/ }
    it { should have_tag 'li', text: /^All/ }
    it { should have_tag 'li', text: /^Drafts/ }
    it { should have_tag 'li', text: /^Trash/ }
    it { should have_tag 'li', text: /^Ignored/ }
  end

  context '#box_participant_slug' do
    subject { helper.box_participant_slug(first_user) }
    it { should eq 'first-user' }
  end

  context '#box_participant_name' do
    subject { helper.box_participant_name(first_user) }
    it { should eq 'First User' }
  end
end
