module Tickets::V1
  class AnalyticalReports < ApplicationController
    def initialize(current_user)
      @current_user = current_user
    end

    def call
      data = {}
      data['status_wise_organization_tickets'] = status_wise_organization_tickets
      data['status_wise_department_tickets'] = status_wise_department_tickets
      data['month_and_status_wise_tickets'] = status_based_month_wise_ticket_categorization
      return {
        status: true,
        data: data
      }.as_json
    end

    private

    def status_based_month_wise_ticket_categorization
      tickets = {}
      tickets['total'] = 0
      date_range = (Time.zone.today-365..Time.zone.today)
      month_range = date_range.group_by(&:beginning_of_month).map { |_, month| month.first..month.last }
      month_range[1..-1].each do |ele|
        tickets["#{Date::MONTHNAMES[ele.first.month]}_#{ele.first.year}"] =
          Ticket.where('created_at >= ? AND created_at <= ? AND organization_id = ?',
                       ele.first.beginning_of_day,
                       ele.last.end_of_day,
                       @current_user.organization_id)
                .group(:status)
                .count
        Ticket.statuses.keys.each do |status|
          tickets["#{Date::MONTHNAMES[ele.first.month]}_#{ele.first.year}"][status] =
            tickets["#{Date::MONTHNAMES[ele.first.month]}_#{ele.first.year}"][status] || 0
          tickets['total'] += tickets["#{Date::MONTHNAMES[ele.first.month]}_#{ele.first.year}"][status]
        end
      end
      tickets
    end

    def status_wise_department_tickets
      all_tickets = Ticket.where(organization_id: @current_user.organization_id)
                          .group(:department_id, :status)
                          .count
      tickets = {}
      tickets['total'] = 0
      Department.where(organization_id: @current_user.organization_id).each do |department|
        department_tickets = {}
        Ticket.statuses.keys.each do |status|
          department_tickets[status] = all_tickets[[department.id, status]] || 0
          tickets['total'] += department_tickets[status]
        end
        department_tickets['total'] = department_tickets.values.sum
        tickets[department.id] = department_tickets
      end
      tickets
    end

    def status_wise_organization_tickets
      tickets = {}
      tickets['total'] = 0
      Ticket.statuses.keys.each do |status|
        tickets[status] = Ticket.all.where(status: status, organization_id: @current_user.organization_id).count
        tickets['total'] += tickets[status]
      end
      tickets
    end
  end
end