require 'rails_helper'

describe MessageTrain::CollectivesHelper do
  include_context 'loaded site'
  include ControllerMacros

  before do
    login_user first_user
  end

  context '#collective_nav_item' do
    subject { helper.collective_nav_item(first_group.box) }
    it { should have_tag 'li', text: /^First Group/ }
    it { should have_tag 'span', text: /[0-9]+/, with: { class: 'badge' } }
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

  context '#collective_path_part' do
    subject { helper.collective_path_part(first_group) }
    it { should eq 'groups:first-group' }
  end

  context '#collective_participant_name' do
    subject { helper.collective_name(first_group) }
    it { should eq 'First Group' }
  end
end