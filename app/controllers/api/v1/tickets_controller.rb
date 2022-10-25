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

    def reopen
      result = Tickets::V1::Reopen.new(params[:ticket_result], params[:id], current_user).call
      if result["status"]
        render json: { message: result["success_message"]  }
      else
        render json: { message: I18n.t('tickets.error.update'), errors: result["error_message"] }, status: :unprocessable_entity
      end
    end

    def index
      result = Tickets::V1::Index.new(params, current_user).call
      if result["status"]
        render json: result["tickets"], status: 200
      else
        render json: {message: result["message"]}, status: result["status_code"]
      end
    end
    
    private


    def update
      begin
        result = Tickets::V1::Update.new(update_params, current_user).call
        byebug
        if result["status"]
          render json: { message: I18n.t('tickets.success.update') }
        else
          render json: { message: I18n.t('tickets.error.update'), errors: result["error_message"] }, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render json:{ message: I18n.t('tickets.error.invalid_params') }, status: :unprocessable_entity
      end
    end

    private

    def update_params
      byebug
      params.require(:ticket).permit(:id, :status, :category_id, :department_id, :resolver_id)
    end

    def ticket_params
      params.require(:ticket).permit(:title, :description, :category_id, :department_id, :ticket_type, :resolver_id)
    end
  end
end
