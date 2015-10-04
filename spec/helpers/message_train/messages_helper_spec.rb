require 'rails_helper'

describe MessageTrain::MessagesHelper do
  include_context 'loaded site'
  include ControllerMacros
  helper MessageTrain::BoxesHelper

  before do
    login_user first_user
    assign(:box_user, first_user)
  end

  describe '#messages_class' do
    context 'when it is unread' do
      subject { helper.message_class(first_user.box(:in), unread_message) }
      it { should match /unread/ }
    end
    context 'when it is read' do
      subject { helper.message_class(first_user.box(:in), read_message) }
      it { should match /read/ }
      it { should_not match /unread/ }
    end
    context 'when it is a draft' do
      subject { helper.message_class(first_user.box(:in), draft_message) }
      it { should match /draft/ }
    end
    context 'when it is trashed' do
      context 'in the inbox' do
        subject { helper.message_class(first_user.box(:in), trashed_message) }
        it { should match /hide/ }
      end
      context 'in the trash box' do
        subject { helper.message_class(first_user.box(:trash), trashed_message) }
        it { should_not match /hide/ }
      end
    end
    context 'when it is not trashed' do
      context 'in the inbox' do
        subject { helper.message_class(first_user.box(:in), unread_message) }
        it { should_not match /hide/ }
      end
      context 'in the trash box' do
        subject { helper.message_class(first_user.box(:trash), unread_message) }
        it { should match /hide/ }
      end
    end
    context 'when it is ignored' do
      context 'in the trash box' do
        subject { helper.message_class(first_user.box(:trash), ignored_message) }
        it { should match /hide/ }
      end
    end
  end

  describe '#message_trashed_toggle' do
    describe 'in a user box' do
      context 'when the message is untrashed' do
        before do
          assign(:box, first_user.box(:in))
        end
        subject { helper.message_trashed_toggle(unread_message) }
        it { should have_tag(:a, with: {
                                   'rel' => 'nofollow',
                                   'title' => 'Mark as Trashed',
                                   'data-confirm' => 'Are you sure?',
                                   'data-method' => 'put',
                                   'data-remote' => 'true'
                               }) }
        it { should have_tag(:span, with: { class: 'glyphicon-trash' }) }
      end
      context 'when the message is trashed' do
        before do
          assign(:box, first_user.box(:trash))
        end
        subject { helper.message_trashed_toggle(trashed_message) }
        it { should have_tag(:a, with: {
                                   'rel' => 'nofollow',
                                   'title' => 'Mark as Untrashed',
                                   'data-method' => 'put',
                                   'data-remote' => 'true'
                               }) }
        it { should have_tag(:span, with: { class: 'glyphicon-inbox' }) }
      end
    end
    describe 'in a collective box' do
      context 'when the message is untrashed' do
        before do
          assign(:box, membered_group.box(:in, first_user))
        end
        subject { helper.message_trashed_toggle(membered_group_message) }
        it { should have_tag(:a, with: {
                                   'rel' => 'nofollow',
                                   'title' => 'Mark as Trashed',
                                   'data-confirm' => 'Are you sure?',
                                   'data-method' => 'put',
                                   'data-remote' => 'true'
                               }) }
        it { should have_tag(:span, with: { class: 'glyphicon-trash' }) }
      end
      context 'when the message is trashed' do
        before do
          assign(:box, membered_group.box(:trash, first_user))
        end
        subject { helper.message_trashed_toggle(membered_group_trashed_message) }
        it { should have_tag(:a, with: {
                                   'rel' => 'nofollow',
                                   'title' => 'Mark as Untrashed',
                                   'data-method' => 'put',
                                   'data-remote' => 'true'
                               }) }
        it { should have_tag(:span, with: { class: 'glyphicon-inbox' }) }
      end
    end
  end

  describe '#message_read_toggle' do
    describe 'in a user box' do
      context 'when the message is unread' do
        before do
          assign(:box, first_user.box(:in))
        end
        subject { helper.message_read_toggle(unread_message) }
        it { should have_tag(:a, with: {
                                   'rel' => 'nofollow',
                                   'title' => 'Mark as Read',
                                   'data-method' => 'put',
                                   'data-remote' => 'true'
                               }) }
        it { should have_tag(:span, with: { class: 'glyphicon-eye-open' }) }
      end
      context 'when the message is read' do
        before do
          assign(:box, first_user.box(:trash))
        end
        subject { helper.message_read_toggle(read_message) }
        it { should have_tag(:a, with: {
                                   'rel' => 'nofollow',
                                   'title' => 'Mark as Unread',
                                   'data-method' => 'put',
                                   'data-remote' => 'true'
                               }) }
        it { should have_tag(:span, with: { class: 'glyphicon-eye-close' }) }
      end
    end
    describe 'in a collective box' do
      context 'when the message is unread' do
        before do
          assign(:box, membered_group.box(:in, first_user))
        end
        subject { helper.message_read_toggle(membered_group_message) }
        it { should have_tag(:a, with: {
                                   'rel' => 'nofollow',
                                   'title' => 'Mark as Read',
                                   'data-method' => 'put',
                                   'data-remote' => 'true'
                               }) }
        it { should have_tag(:span, with: { class: 'glyphicon-eye-open' }) }
      end
      context 'when the message is read' do
        before do
          assign(:box, membered_group.box(:trash, first_user))
        end
        subject { helper.message_read_toggle(membered_group_read_message) }
        it { should have_tag(:a, with: {
                                   'rel' => 'nofollow',
                                   'title' => 'Mark as Unread',
                                   'data-method' => 'put',
                                   'data-remote' => 'true'
                               }) }
        it { should have_tag(:span, with: { class: 'glyphicon-eye-close' }) }
      end
    end
  end

  describe '#message_deleted_toggle' do
    describe 'in a user box' do
      context 'when the message is undeleted' do
        before do
          assign(:box, first_user.box(:trash))
        end
        subject { helper.message_deleted_toggle(unread_message) }
        it { should have_tag(:a, with: {
                                   'rel' => 'nofollow',
                                   'title' => 'Mark as Deleted',
                                   'data-confirm' => 'Delete forever? This cannot be undone.',
                                   'data-method' => 'put',
                                   'data-remote' => 'true'
                               }) }
        it { should have_tag(:span, with: { class: 'glyphicon-remove' }) }
      end
    end
    describe 'in a collective box' do
      context 'when the message is undeleted' do
        before do
          assign(:box, membered_group.box(:trash, first_user))
        end
        subject { helper.message_deleted_toggle(membered_group_message) }
        it { should have_tag(:a, with: {
                                   'rel' => 'nofollow',
                                   'title' => 'Mark as Deleted',
                                   'data-confirm' => 'Delete forever? This cannot be undone.',
                                   'data-method' => 'put',
                                   'data-remote' => 'true'
                               }) }
        it { should have_tag(:span, with: { class: 'glyphicon-remove' }) }
      end
    end
  end

  describe '#message_recipients' do
    subject { helper.message_recipients(to_many_message) }
    it { should match /^([^\,]+\,){2} and ([^\,]+)$/ }
    it { should match /Second User/ }
    it { should match /Third User/ }
    it { should match /Fourth User/ }
  end
end