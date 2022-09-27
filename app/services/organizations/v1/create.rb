module Organizations::V1
  class Create
    def initialize(organization, current_user)
      @name = organization[:name]
      @domain = organization[:domain]
      @current_user = current_user
    end

    def call
      not_exists = !check_existing_organization_name && save_organization
      not_exists ? { status: true } : { status: false }
    end

    def check_existing_organization_name
      Organization.find_by(name: @name)
    end

    def save_organization
      @new_organization = Organization.new(name: @name, domain: @domain)
      if @new_organization.save
        { status: true }.as_json
      else
        { status: false, error_message: @new_organization.errors.full_messages.join(", ") }.as_json
      end
    end
  end
end