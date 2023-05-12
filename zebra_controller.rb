# frozen_string_literal: true

module Api
  module Ecosystem
    module V1
      module Insurance
        # Zebra Insurance Partner Integration
        class ZebraController < Api::Ecosystem::V1::ApiController
          before_action -> { check_feature_flag!(INSURANCE_ZEBRA) }

          def create
            render json: { error: 'No Vehicle Found' } and return if current_customer.active_vehicles.blank?

            response = ZebraService.new(params: zebra_params, user_id: current_customer.id).call

            unless response.code.eql?('500')
              render json: response.body, status: response.code
            else
              render json: {'messages' =>
                             {'vehicles' =>
                               {'0' => {invalid_request: I18n.t('general_errors.invalid_request')}
                             }
                           }
                          }, status: :unprocessable_entity
            end
          end

          private

          def zebra_params
            params.permit(:mileage, :vehicle_id)
          end
        end
      end
    end
  end
end
