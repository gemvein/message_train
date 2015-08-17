require 'rails_helper'

describe NightTrain::BoxesHelper do
  include_context 'loaded site'
  include ControllerMacros

  before do
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
    subject { helper.boxes_widget }
    it { should have_tag 'h3', text: /Messages/ }
    it { should have_tag 'ul', with: { class: 'list-group' } }
    it { should have_tag 'li', with: { class: 'list-group-item' }, count: 6 }
  end

  context '#boxes_dropdown_list' do
    subject { helper.boxes_dropdown_list }
    it { should have_tag 'ul', with: { class: 'dropdown-menu' } }
    it { should have_tag 'li', minimum: 5 }
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