module::Users::V1
  class Update
    def initialize(user_data, current_user, id)
      @id = id
      @name = user_data[:name]
      @email = user_data[:email]
      @role_id = user_data[:role_id]
      @organization_id = user_data[:organization_id]
      @department_id = user_data[:department_id]
      @current_user = current_user
    end

    def call
      return { status: false } unless User.exists?(@id) && @id.to_i == @current_user[:id]
      user = User.find @id.to_i
      user.name = @name if @name
      user.email = @email if @email
      user.role_id = @role_id if @role_id
      user.organization_id = @organization_id if @organization_id
      user.department_id = @department_id if @department_id

      user.save ? { status: true } : { status: false }
    end
  end
end