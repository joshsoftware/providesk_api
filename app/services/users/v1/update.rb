module Users::V1
  class Update
    def initialize(user_update_params, user_id)
      @user_id = user_id
      @role = user_update_params[:role]
      @department_id = user_update_params[:department_id]
      @category_ids = user_update_params[:category_ids]
    end

    def call
      check_user && find_department && find_categories && check_role && user_update
    end

    def check_user
      if @user = User.find_by(id: @user_id)
        return true
      else 
        @error = { status: false, error_message: I18n.t('users.error.not_exists') }.as_json
      end
    end

    def find_department
      if @department_id.present?
        @department = Department.find_by(organization_id: User.find(@user_id).organization_id, id: @department_id)
        return @department.nil? ? (@error = { status: false, error_message: I18n.t('tickets.error.department') }.as_json) 
                                : @user.department_id = @department.id
      else 
        return true
      end
      return true if @department

      @error = { status: false, error_message: I18n.t('tickets.error.department') }.as_json
    end

    def find_categories
      @category_list = Category.where(id: @category_ids)
    end

    def check_role
      if @role.present?
        @role = Role.find_by(name: @role)
        return @role.nil? ? (@error = { status: false, error_message: I18n.t('users.error.role') }.as_json) 
                          : @user.role_id = @role.id
      else
        return true
      end
      return true if @role
    end

    def user_update
      return @error if @error

      @user.user_categories.destroy_all if @user.user_categories.count > 0
      @category_list.each do |category|
        @user.user_categories.create(:category => category)
      end
      @user.save! if @user.changed?
      { status: true }.as_json
    end
  end
end