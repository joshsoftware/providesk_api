# frozen_string_literal: true

module Api::V1
  class TicketsController < ApplicationController
    def create
      begin
        result = Tickets::V1::Create.new(ticket_params, current_user).call
        if result[:status]
          render json: { message: I18n.t('tickets.success.create') }
        else
          render json: { message: I18n.t('tickets.error.create'), errors: result[:error_message]},
                status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render json:{ message: I18n.t('tickets.error.invalid_params') }, status: :unprocessable_entity
      end
    end

    private

    def ticket_params
      params.require(:ticket).permit(:title, :description, :category_id, :department_id, :ticket_type, :resolver_id)
    end
  end
end
