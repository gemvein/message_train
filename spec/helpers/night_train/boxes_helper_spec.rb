require 'rails_helper'

describe NightTrain::BoxesHelper do
  include_context 'loaded site'
  include ControllerMacros

  context '#box_nav_item' do
    before do
      login_user first_user
    end
    subject { helper.box_nav_item(:in) }
    it { should have_tag 'li', text: /Inbox/ }
    it { should have_tag 'span', text: /[0-9]+/, with: { class: 'badge' } }
  end
end