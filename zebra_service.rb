# frozen_string_literal: true

require 'net/http'
require 'uri'

# This service is used by Zebra Controller to send the request to Zebra 
# Insurance Partner
class ZebraService < EcoSystemService
  attr_accessor :mileage

  ACCESS_TOKEN = ENV['ZEBRA_ACCESS_TOKEN'].freeze
  IS_TEST = ENV['ZEBRA_IS_TEST'].freeze

  def initialize(args = {})
    super
    @base    = ENV['ZEBRA_BASE_URL']
    @mileage = params[:mileage]
    @path    = build_url('prepop/')
    @params  = build_body
    @header  = headers
  end

  def call
    uri = URI.parse(path)
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request['Authorization'] = headers
    request.body = JSON.dump(params)
    send_uri_request(uri, request)
  end

  def build_body
    {
      first_name: user.firstName,
      last_name: user.lastName,
      email: user.email,
      zipcode: user.zip,
      is_test: IS_TEST,
      drivers: drivers,
      vehicles: vehicles
    }
  end

  def drivers
    [{
      first_name: user.firstName,
      last_name: user.lastName
    }]
  end

  def vehicles
    [{
      year: vehicle.year,
      make: vehicle.make,
      model: vehicle.model,
      submodel: vehicle.sub_model,
      miles_per_year: mileage || vehicle.miles
    }]
  end

  def headers
    "Bearer #{ACCESS_TOKEN}"
  end
end

