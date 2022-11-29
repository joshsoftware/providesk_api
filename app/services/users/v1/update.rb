module Users::V1
  class Update
    def initialize(user_update_params, user_id)
      @user_id = user_id
      @role = user_update_params[:role]
      @department_id = user_update_params[:department_id]
    end

    def call
      check_user && check_department && check_role && user_update
    end

    def check_user
      if @user = User.find_by(id: @user_id)
        return true
      else 
        @error = { status: false, error_message: I18n.t('users.error.not_exists') }.as_json
      end
    end

    def check_department
      if @department_id.present?
        @department = Department.find_by(organization_id: User.find(@user_id).organization_id, id: @department_id)
      else 
        return true
      end
      return true if @department

      @error = { status: false, error_message: I18n.t('tickets.error.department') }.as_json
    end

    def check_role
      if @role.present?
        @role = Role.find_by(name: @role)
        return @role.nil? ? (@error = { status: false, error_message: I18n.t('users.error.role') }.as_json) : @user.role_id = @role.id
      else
        return true
      end
      return true if @role
    end

    def user_update
      return @error if @error
      
      @user.save! if @user.changed?
      { status: true }.as_json
    end
  end
end