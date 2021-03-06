class ApplicationController < ActionController::Base
  @@factory = Proc.new {|instance| instance}
  protect_from_forgery with: :exception

  before_action :initialize_client

  attr_accessor :api_client

  def initialize_client(service = NexosisApi.client(api_key: Rails.application.secrets.api_key, base_uri: ENV['NEXOSIS_BASE_URL']))
    @api_client = @@factory.call service
  end

  def self.initialize_factory(factory)
    @@factory = factory
  end
end
