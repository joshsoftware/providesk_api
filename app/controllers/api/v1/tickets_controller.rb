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
      result = Tickets::V1::Update.new(params[:ticket_result], params[:id], current_user).call
      if result["status"]
        render json: { message: result["success_message"]  }
      else
        render json: { message: I18n.t('ticket.error.update')}, status: :unprocessable_entity
      end
    end

    def index
      result = Tickets::V1::Index.new(params).call
      if result["status"]
        render json: result["tickets"], status: 200
      else
        render json: {message: result["message"]}, status: result["status_code"]
      end
    end

  end
end
