# Copyright 2017-2022 Provide Technologies Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Provide
  module Services
    class Tourguide < Provide::ApiClient

      def initialize(scheme = 'http', host, token)
        @scheme = scheme
        @host = host
        @token = token
      end

      def directions(from_latitude, from_longitude, to_latitude, to_longitude, waypoints = nil, departure = 'now', alternatives = 0)
        parse client.get('directions', {
          :alternatives => alternatives,
          :departure => departure,
          :from_latitude => from_latitude,
          :from_longitude => from_longitude,
          :to_latitude => to_latitude,
          :to_longitude => to_longitude,
          :waypoints => waypoints,
        })
      end

      def eta(from_latitude, from_longitude, to_latitude, to_longitude, waypoints = nil, departure = 'now', alternatives = 0)
        parse client.get('directions/eta', {
          :alternatives => alternatives,
          :departure => departure,
          :from_latitude => from_latitude,
          :from_longitude => from_longitude,
          :to_latitude => to_latitude,
          :to_longitude => to_longitude,
          :waypoints => waypoints,
        })
      end

      def geocode(street_number = nil, street = nil, city = nil, state = nil, postal_code = nil)
        parse client.get('geocoder', {
          :street_number => street_number,
          :street => street,
          :city => city,
          :state => state,
          :postal_code => postal_code,
        })
      end

      def reverse_geocode(latitude, longitude)
        parse client.get('geocoder', {
          :latitude => latitude,
          :longitude => longitude,
        })
      end

      def matrix(origin_coords, destination_coords)
        parse client.get('matrix', {
          :origin_coords => origin_coords,
          :destination_coords => destination_coords,
        })
      end

      def place_details(place_id)
        parse client.get('places', {
          :place_id => place_id,
        })
      end

      def places_autocomplete(query, latitude, longitude, radius = 15, type = nil, components = nil)
        params = {
          :q => query,
          :latitude => latitude,
          :longitude => longitude,
          :radius => radius,
        }
        params[:type] = type if type
        params[:components] = components = components if components
        parse client.get('places/autocomplete', params)
      end

      def timezones(latitude, longitude)
        parse client.get('timezones', {
          :latitude => latitude,
          :longitude => longitude,
        })
      end

      private

      def client
        @client ||= begin
          Provide::ApiClient.new(@scheme, @host, 'api/v1/', @token)
        end
      end

      def parse(response)
        begin
          body = response.code == 204 ? nil : JSON.parse(response.body)
          return response.code, response.headers, body
        rescue
          raise Exception.new({
            :code => response.code,
          })
        end
      end
    end
  end
end
