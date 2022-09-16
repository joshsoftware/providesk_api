# frozen_string_literal: true

module Api
  module V1
    class TicketsController < BaseController
      def create
        result = Tickets::V1::Create.new(params).call
        if result
          render json: { message: I18n.t('ticket.success.create') }
        else
          render json: { message: I18n.t('ticket.error.create') }
        end
      end
    end
  end
end
