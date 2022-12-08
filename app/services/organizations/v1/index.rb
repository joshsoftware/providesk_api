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
            organizations: organizations.order(name: :asc)
          }
        }.as_json
    end
  end
end