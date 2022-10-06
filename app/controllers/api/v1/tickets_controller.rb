# frozen_string_literal: true

module Api::V1
  class TicketsController < ApplicationController
    def create
      result = Tickets::V1::Create.new(params[:ticket], current_user).call
      if result["status"]
        render json: { message: I18n.t('tickets.success.create') }
      else
        render json: { message: I18n.t('tickets.error.create') }, status: :unprocessable_entity
      end
    end

    def show
      result = Tickets::V1::Show.new(params).call
      if result
        render json: result
      else
        render json: { message: I18n.t('tickets.error.show') }, status: :unprocessable_entity
      end
    end
  end
end
