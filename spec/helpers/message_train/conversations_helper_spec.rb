require 'rails_helper'

describe MessageTrain::ConversationsHelper do
  include_context 'loaded site'
  include ControllerMacros
  helper MessageTrain::BoxesHelper

  before do
    login_user first_user
    assign(:box_user, first_user)
  end

  describe '#conversation_senders' do
    context 'when there is one sender' do
      subject { helper.conversation_senders(sent_conversation) }
      it { should eq 'First User' }
    end
    context 'when there is more than one sender' do
      subject { helper.conversation_senders(long_conversation) }
      it { should eq 'First User and Second User' }
    end
  end

  describe '#conversation_class' do
    context 'when it is unread' do
      context 'in the inbox' do
        subject do
          helper.conversation_class(first_user.box(:in), unread_conversation)
        end
        it { should match(/unread/) }
      end
      context 'in the ignored box' do
        subject do
          helper.conversation_class(
            first_user.box(:ignored),
            unread_conversation
          )
        end
        it { should match(/hide/) }
      end
    end
    context 'when it is read' do
      subject do
        helper.conversation_class(first_user.box(:in), read_conversation)
      end
      it { should match(/read/) }
      it { should_not match(/unread/) }
    end
    context 'when it is a draft' do
      subject do
        helper.conversation_class(first_user.box(:in), draft_conversation)
      end
      it { should match(/draft/) }
    end
    context 'when it is deleted' do
      subject do
        helper.conversation_class(first_user.box(:in), deleted_conversation)
      end
      it { should match(/hide/) }
    end
    context 'when it is trashed' do
      context 'in the inbox' do
        subject do
          helper.conversation_class(first_user.box(:in), trashed_conversation)
        end
        it { should match(/hide/) }
      end
      context 'in the trash box' do
        subject do
          helper.conversation_class(
            first_user.box(:trash),
            trashed_conversation
          )
        end
        it { should_not match(/hide/) }
      end
    end
    context 'when it is not trashed' do
      context 'in the inbox' do
        subject do
          helper.conversation_class(first_user.box(:in), unread_conversation)
        end
        it { should_not match(/hide/) }
      end
      context 'in the trash box' do
        subject do
          helper.conversation_class(first_user.box(:trash), unread_conversation)
        end
        it { should match(/hide/) }
      end
    end
    context 'when it is ignored' do
      context 'in the ignored box' do
        subject do
          helper.conversation_class(
            first_user.box(:ignored), ignored_conversation
          )
        end
        it { should_not match(/hide/) }
      end
      context 'in the trash box' do
        subject do
          helper.conversation_class(
            first_user.box(:trash),
            ignored_conversation
          )
        end
        it { should match(/hide/) }
      end
    end
  end

  describe '#conversation_trashed_toggle' do
    describe 'in a user box' do
      context 'when the conversation has untrashed messages' do
        before do
          assign(:box, first_user.box(:in))
        end
        subject { helper.conversation_trashed_toggle(unread_conversation) }
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Trashed',
              'data-confirm' => 'Are you sure?',
              'data-method' => 'put',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-trash' }) }
      end
      context 'when the conversation is all trashed' do
        before do
          assign(:box, first_user.box(:trash))
        end
        subject { helper.conversation_trashed_toggle(trashed_conversation) }
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Untrashed',
              'data-method' => 'put',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-inbox' }) }
      end
    end
    describe 'in a collective box' do
      context 'when the conversation has untrashed messages' do
        before do
          assign(:box, membered_group.box(:in, first_user))
        end
        subject do
          helper.conversation_trashed_toggle(membered_group_conversation)
        end
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Trashed',
              'data-confirm' => 'Are you sure?',
              'data-method' => 'put',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-trash' }) }
      end
      context 'when the conversation is all trashed' do
        before do
          assign(:box, membered_group.box(:trash, first_user))
        end
        subject do
          helper.conversation_trashed_toggle(
            membered_group_trashed_conversation
          )
        end
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Untrashed',
              'data-method' => 'put',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-inbox' }) }
      end
    end
  end

  describe '#conversation_read_toggle' do
    describe 'in a user box' do
      context 'when the conversation has unread messages' do
        before do
          assign(:box, first_user.box(:in))
        end
        subject { helper.conversation_read_toggle(unread_conversation) }
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Read',
              'data-method' => 'put',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-eye-open' }) }
      end
      context 'when the conversation is all read' do
        before do
          assign(:box, first_user.box(:trash))
        end
        subject { helper.conversation_read_toggle(read_conversation) }
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Unread',
              'data-method' => 'put',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-eye-close' }) }
      end
    end
    describe 'in a collective box' do
      context 'when the conversation has unread messages' do
        before do
          assign(:box, membered_group.box(:in, first_user))
        end
        subject { helper.conversation_read_toggle(membered_group_conversation) }
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Read',
              'data-method' => 'put',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-eye-open' }) }
      end
      context 'when the conversation is all read' do
        before do
          assign(:box, membered_group.box(:trash, first_user))
        end
        subject do
          helper.conversation_read_toggle(membered_group_read_conversation)
        end
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Unread',
              'data-method' => 'put',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-eye-close' }) }
      end
    end
  end

  describe '#conversation_ignored_toggle' do
    describe 'in a user box' do
      context 'when the conversation has unignored messages' do
        before do
          assign(:box, first_user.box(:in))
        end
        subject { helper.conversation_ignored_toggle(unread_conversation) }
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Ignored',
              'data-confirm' => 'Are you sure?',
              'data-method' => 'delete',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-volume-off' }) }
      end
      context 'when the conversation is all ignored' do
        before do
          assign(:box, first_user.box(:trash))
        end
        subject { helper.conversation_ignored_toggle(ignored_conversation) }
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Unignored',
              'data-method' => 'delete',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-volume-up' }) }
      end
    end
    describe 'in a collective box' do
      context 'when the conversation has unignored messages' do
        before do
          assign(:box, membered_group.box(:in, first_user))
        end
        subject do
          helper.conversation_ignored_toggle(membered_group_conversation)
        end
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Ignored',
              'data-confirm' => 'Are you sure?',
              'data-method' => 'delete',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-volume-off' }) }
      end
      context 'when the conversation is all ignored' do
        before do
          assign(:box, membered_group.box(:trash, first_user))
        end
        subject do
          helper.conversation_ignored_toggle(
            membered_group_ignored_conversation
          )
        end
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Unignored',
              'data-method' => 'delete',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-volume-up' }) }
      end
    end
  end

  describe '#conversation_deleted_toggle' do
    describe 'in a user box' do
      context 'when the conversation has undeleted messages' do
        before do
          assign(:box, first_user.box(:trash))
        end
        subject { helper.conversation_deleted_toggle(unread_conversation) }
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Deleted',
              'data-confirm' => 'Delete forever? This cannot be undone.',
              'data-method' => 'put',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-remove' }) }
      end
    end
    describe 'in a collective box' do
      context 'when the conversation has undeleted messages' do
        before do
          assign(:box, membered_group.box(:trash, first_user))
        end
        subject do
          helper.conversation_deleted_toggle(membered_group_conversation)
        end
        it do
          should have_tag(
            :a,
            with: {
              'rel' => 'nofollow',
              'title' => 'Mark as Deleted',
              'data-confirm' => 'Delete forever? This cannot be undone.',
              'data-method' => 'put',
              'data-remote' => 'true'
            }
          )
        end
        it { should have_tag(:span, with: { class: 'glyphicon-remove' }) }
      end
    end
  end
end
