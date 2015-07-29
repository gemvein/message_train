require 'rails_helper'

describe 'NightTrain::Routing::Boxes' do
  include_context 'loaded site'
  routes { NightTrain::Engine.routes }

  describe 'routes to show a box' do
    subject { get '/box/in' }
    it { should route_to(controller: 'night_train/boxes', action: 'show', division: 'in')}
  end
  describe 'routes to update a box' do
    subject { put '/box/in' }
    it { should route_to(controller: 'night_train/boxes', action: 'update', division: 'in')}
  end
  describe 'routes to ignore(delete) within a box' do
    subject { delete '/box/in' }
    it { should route_to(controller: 'night_train/boxes', action: 'destroy', division: 'in')}
  end

end