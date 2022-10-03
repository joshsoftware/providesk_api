module Users::V1
  class Create
    def initialize(user)
      @name = user[:name]
      @email = user[:email]
      @role_id = user[:role_id]
      @organization_id = user[:organization_id]
      @department_id = user[:department_id]
    end

    def call
      @user = User.new(name: @name,
                      email: @email,
                      role_id: @role_id,
                      organization_id: @organization_id,
                      department_id: @department_id)
      if @user.save
        { status: true }
      else
        { status: false, error_message: @user.errors.full_messages.join(', ') }
      end
    end
  end
end 