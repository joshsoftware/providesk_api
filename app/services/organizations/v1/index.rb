module Organizations::V1
  class Index
    def initialize
    end

    def call
      organizations = Organization.all.select(:id, :name)
        { 
          status: true,
          data: {
            total: organizations.length,
            organizations: organizations.order(created_at: :desc)
          }
        }.as_json
    end
  end
end