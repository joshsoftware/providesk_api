# frozen_string_literal: true

module Api::V1
  class TicketsController < ApplicationController
    def create
      result = Tickets::V1::Create.new(ticket_params, current_user).call
      if result[:status]
        render json: { message: I18n.t('tickets.success.create') }
      else
        render json: { message: I18n.t('tickets.error.create'), errors: result[:error_message]},
              status: :unprocessable_entity
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
        render json: { data: result["tickets"] }, status: 200
      else
        render json: { message: result["message"], data: result["data"] }, status: result["status_code"]
      end
    end

    def update
      result = Tickets::V1::Update.new(ticket_params, params[:id]).call
      if result["status"]
        render json: { message: I18n.t('tickets.success.update') }
      else
        render json: { message: I18n.t('tickets.error.update'), errors: result["error_message"] }, status: :unprocessable_entity
      end
    end

    def update_ticket_progress
      result = Tickets::V1::UpdateTicketProgress.new(update_params, current_user).call
      if result["status"]
        render json: { message: I18n.t('tickets.success.update') }
      else
        render json: { message: I18n.t('tickets.error.update'), errors: result["error_message"] }, status: :unprocessable_entity
      end
    end

    def bulk_update_ticket_progress
      result = Tickets::V1::BulkUpdateTicketProgress.new(bulk_update_params).call
      if result["status"]
        render json: { message: I18n.t('tickets.success.update') }
      else
        render json: { message: I18n.t('tickets.error.update'), errors: result["error_message"] }, status: :unprocessable_entity
      end
    end

    def show
      result = Tickets::V1::Show.new(params, current_user).call
      if result["status"]
        render json: { data: { ticket: result["data"], activities: result["activities"]} }
      else
        render json: { message: I18n.t('tickets.error.not_exists') }, status: :unprocessable_entity
      end
    end

    def ask_for_update
      result = Tickets::V1::AskForUpdate.new(params).call
      if result["status"]
        render json: { message: I18n.t('tickets.success.ask_for_update')}
      else
        render json: { message: I18n.t('tickets.error.ask_for_update') }, status: :unprocessable_entity
      end
    end

    def timeline
      result = Tickets::V1::Timeline.new(current_user).call
      if result["status"]
        render json: { data: result["data"] }
      else
        render json: { erros: result["error_message"] }, status: :unprocessable_entity
      end
    end

    def analytical_reports
      result = Tickets::V1::AnalyticalReports.new(current_user).call
      if result["status"]
        render json: { data: result["data"] }
      else
        render json: { erros: result["error_message"] }, status: :unprocessable_entity
      end
    end

    def create_presigned_url
      bucket_name = Rails.application.credentials[:aws][:bucket_name] 
      object_key = params[:object_key] 

      presigned_url = S3Service.new.get_presigned_url(bucket_name, object_key, :put)

      render json: { url: presigned_url }
    rescue => e 
      render json: { message: I18n.t('tickets.error.presigned url')}, status: :unprocessable_entity    
    end

    def presigned_url_for_get
      bucket_name = 'josh-intranet-v1'
      object_key = params[:object_key]
  
      presigned_url = S3Service.new.get_presigned_url(bucket_name, object_key, :get)
  
      render json: { url: presigned_url }
    rescue => e
      render json: { message: I18n.t('tickets.error.presigned_url') }, status: :unprocessable_entity
    end

    private

    def update_params
      params.require(:ticket).permit(:status, :category_id, :department_id, :resolver_id, :reason_for_update, :eta, asset_url: []).merge(id: params[:id])
    end

    def ticket_params
      params.require(:ticket).permit(:title, :description, :category_id, :department_id, :ticket_type, :resolver_id, asset_url: [])
    end

    def bulk_update_params
      params.require(:ticket).permit(:resolver_id, :category_id, :department_id, :status, ticket_ids: [])
    end
  end
end
