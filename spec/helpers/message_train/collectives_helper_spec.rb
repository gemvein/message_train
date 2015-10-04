require 'rails_helper'

describe MessageTrain::CollectivesHelper do
  include_context 'loaded site'
  include ControllerMacros

  before do
    login_user first_user
  end

  describe '#collective_boxes_widget' do
    subject { helper.collective_boxes_widget(membered_group, first_user) }
    it { should have_tag 'h3', text: /Membered Group Messages/ }
    it { should have_tag 'ul', with: { class: 'list-group' } }
    it { should have_tag 'li', with: { class: 'list-group-item' }, count: 4 }
  end

  describe '#collective_nav_item' do
    context 'when no messages are unread' do
      subject { helper.collective_nav_item(first_group.box(:in, first_user), first_user) }
      it { should have_tag 'li', text: /^First Group/ }
      it { should_not have_tag 'span', with: { class: 'badge' } }
    end
    context 'when there are unread messages' do
      subject { helper.collective_nav_item(membered_group.box(:in, first_user), first_user) }
      it { should have_tag 'li', text: /^Membered Group/ }
      it { should have_tag 'span', text: /[0-9]+/, with: { class: 'badge' } }
    end
  end

  describe '#collective_list_item' do
    context 'when user is a valid sender and box is sent' do
      subject { helper.collective_list_item(first_group.box(:sent, first_user)) }
      it { should have_tag 'li', text: /^Sent/ }
      it { should have_tag 'span', text: /[0-9]+/, with: { class: 'badge' } }
    end
    context 'when user is a valid recipient and box is in' do
      subject { helper.collective_list_item(membered_group.box(:in, first_user)) }
      it { should have_tag 'li', text: /^Inbox/ }
      it { should have_tag 'span', text: /[0-9]+/, with: { class: 'badge' } }
    end
  end

  describe '#collective_boxes_dropdown_list' do
    subject { helper.collective_boxes_dropdown_list(first_user) }
    it { should have_tag 'ul', with: { class: 'dropdown-menu' }, count: 1 }
    it { should have_tag 'li', text: /^First Group/ }
    it { should have_tag 'li', text: /^Membered Group/ }
  end

  context '#collective_slug' do
    subject { helper.collective_slug(first_group) }
    it { should eq 'first-group' }
  end

  context '#collective_name' do
    subject { helper.collective_name(first_group) }
    it { should eq 'First Group' }
  end
end