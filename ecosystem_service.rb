# frozen_string_literal: true

# This is the base/parent class for all other services classes
class EcoSystemService
  attr_accessor :verb, :params, :path, :user, :header, :base, :vehicle

  def initialize(args = {})
    @verb   = args[:verb]&.downcase || 'get'
    @path   = args[:path]
    @params = args[:params] || {}
    @user   = current_user(args[:user_id])
    @header = headers
    @vehicle = active_vehicle
  end

  # def call
  #   params.delete(:vehicle_id) if params[:vehicle_id]
  #   HTTParty.send(verb,
  #                 path,
  #                 body: JSON(params),
  #                 headers: header)
  # end

  def headers
    {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  def active_vehicle
    if params[:vehicle_id].present?
      user.active_vehicles.find_by(id: params[:vehicle_id])
    else
      user.active_vehicles.last
    end
  end

  def current_user(user_id)
    Customer.find_by_id(user_id)
  end

  def build_url(url)
    "#{base}#{url}"
  end

  def send_uri_request(uri, request)
    req_options = {
      use_ssl: (uri.instance_of? URI::HTTPS)
    }

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end

  def prepare_request(uri, request_type='Get', content_type=nil)
    request = "Net::HTTP::#{request_type}".constantize.new(uri)
    request.content_type = content_type if content_type.present?
    request['Authorization'] = headers
    request
  end
end
