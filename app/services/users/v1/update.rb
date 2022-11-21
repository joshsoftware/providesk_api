module Users::V1
  class Update
    def initialize(user_update_params, current_user, user_id)
      @user_id = user_id
      @role = user_update_params[:role]
      @department_id = user_update_params[:department_id]
      @current_user = current_user
    end

    def call
      check_user && check_role && user_update
    end

    def check_user
      if @user = User.find_by(id: @user_id)
        return true
      else 
        @error = { status: false, error_message: I18n.t('users.error.not_exists') }.as_json
      end
    end

    def check_role
      return @error if @error
      if @current_user.is_super_admin? ||
         @current_user.is_admin? && @user.organization_id == @current_user.organization_id ||
         @current_user.is_department_head? && ((@user.department_id == @current_user.department_id) || 
                                               (@user.department_id.nil? && @user.organization_id == @current_user.organization_id))
        return true if assign_attributes
      elsif !@current_user.is_admin? && !@current_user.is_department_head? && !@current_user.is_super_admin?
        @error = { status: false, error_message: I18n.t('users.error.role') }.as_json
      else
        @error = { status: false, error_message: I18n.t('users.error.organization') }.as_json
      end
    end

    def user_update
      return @error if @error
      @user.save! if @user.changed?
      return { status: true }.as_json
    end

    private

    def assign_attributes
      if @role.present? && assign_role_if_present
        @user.role_id = assign_role_if_present.id
      end
      if @department_id.present? && assign_department_if_present
        @user.department_id = @department_id 
      end
      true
    end

    def assign_role_if_present
      Role.find_by(name: @role)
    end

    def assign_department_if_present
      Department.find_by(organization_id: User.find(@user_id).organization_id, id: @department_id).present?
    end
  end
end