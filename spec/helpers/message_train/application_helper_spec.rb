require 'rails_helper'

describe MessageTrain::ApplicationHelper do
  include_context 'loaded site'
  include ControllerMacros

  before do
    view.extend MessageTrain::BoxesHelper
    view.extend MessageTrain::CollectivesHelper
    view.extend MessageTrain::ApplicationHelper
    login_user first_user
  end

  describe '#message_train_widget' do
    context 'when @collective is nil' do
      before do
        allow(helper).to receive(:controller_name) { 'boxes' }
        assign(:collective, nil)
        assign(:box_user, first_user)
      end
      subject { helper.message_train_widget }
      it { is_expected.to have_tag 'h3', text: /Messages/ }
      it { is_expected.to have_tag 'ul', with: { class: 'list-group' } }
      it { is_expected.to have_tag 'li', with: { class: 'list-group-item' }, count: 6 }
    end
    context 'when @collective is set' do
      before do
        allow(helper).to receive(:controller_name) { 'boxes' }
        assign(:collective, membered_group)
        assign(:box_user, first_user)
      end
      subject { helper.message_train_widget }
      it { is_expected.to have_tag 'h3', text: /Membered Group Messages/ }
      it { is_expected.to have_tag 'ul', with: { class: 'list-group' } }
      it { is_expected.to have_tag 'li', with: { class: 'list-group-item' }, count: 4 }
    end
  end

  describe '#fuzzy_date' do
    context 'when less than a minute ago' do
      subject { helper.fuzzy_date(30.seconds.ago) }
      it { is_expected.to eq 'Just Now' }
    end
    context 'when less than an day ago' do
      subject { helper.fuzzy_date(2.hours.ago) }
      it { is_expected.to eq 2.hours.ago.strftime('%l:%M %p') }
    end
    context 'when less than a week ago' do
      subject { helper.fuzzy_date(2.days.ago) }
      it { is_expected.to eq 2.days.ago.strftime('%a %l:%M %p') }
    end
    context 'when less than a year ago' do
      subject { helper.fuzzy_date(2.months.ago) }
      it { is_expected.to eq 2.months.ago.strftime('%b %-d') }
    end
    context 'when more than a year ago' do
      subject { helper.fuzzy_date(2.years.ago) }
      it { is_expected.to eq 2.years.ago.strftime('%b %-d, %Y') }
    end
  end
end
