module Tickets::V1
  class Create
    attr_accessor :title, :description, :ticket

    def initialize(params)
      @current_user = params[:current_user]
      @title = params[:title]
      @description = params[:description]
    end

    def call
      save
    end

    def save
      @ticket = Ticket.create!(title: title, description: description)
      return true if ticket

      false
    end
  end
end
