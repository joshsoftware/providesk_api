module Organizations::V1
  class Create
    def initialize(organization)
      @name = organization[:name]
      @domain = organization[:domain]
    end

    def call
      not_exists = check_existing_organization_name
      return not_exists unless not_exists[:status]
      not_exists = save_organization
      not_exists[:status] ? { status: true } : not_exists
    end

    def check_existing_organization_name
      organization = Organization.find_by(name: @name)
      if organization
        { status: false, error_message: I18n.t('organizations.error.exists') }
      else
        { status: true }
      end
    end

    def save_organization
      @new_organization = Organization.new(name: @name, domain: @domain)
      if @new_organization.save
        { status: true }
      else
        { status: false, error_message: @new_organization.errors.full_messages.join(", ") }
      end
    end
  end
end