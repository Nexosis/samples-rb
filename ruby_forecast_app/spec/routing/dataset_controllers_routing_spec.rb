require 'rails_helper'

RSpec.describe DatasetController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(:get => '/dataset').to route_to('dataset#index')
    end

    it 'routes to #new' do
      expect(:get => '/dataset/delete/dsname').to route_to('dataset#delete', :dataset_name => 'dsname')
    end

    it 'routes to #detail' do
      expect(:get => '/dataset/detail/dsname').to route_to('dataset#detail', :dataset_name => 'dsname')
    end

    it 'routes to #update' do
      expect(:post => '/dataset/update').to route_to('dataset#update')
    end
  end
end
