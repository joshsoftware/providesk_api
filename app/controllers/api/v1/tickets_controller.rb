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

    def update
      ticket = Ticket.find(update_params[:id])
      if ticket.present?
        update_attributes = {
          category_id: update_params[:category_id],
          department_id: update_params[:department_id],
          resolver_id: update_params[:resolver_id]
        }
        ticket.assign_attributes(update_attributes)
        begin
          ticket.save! if ticket.changed?
          ticket.set_status(update_params[:status])
          render json: { message: 'Ticket updated', data: {ticket_details: ticket} }, status: :ok
        rescue StandardError => e
          render json: { message: e.message , data: {ticket_details: ticket} },
                 status: :unprocessable_entity
        end
      else
        render json: { message: 'Ticket not found' }, status: :unprocessable_entity
      end
    end

    private

    def update_params
      params.require(:ticket).permit(:id, :status, :category_id, :department_id, :resolver_id)
    end
  end
end
