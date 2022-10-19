module Categories::V1
  class Create
    def initialize(categories, current_user)
      @name = categories[:name]
      @priority = categories[:priority].to_i
      @department_id = categories[:department_id]
      @current_user = current_user
    end

    def call
      not_exists = check_existing_category_name
      return not_exists unless not_exists[:status]
      not_exists = save_category
      not_exists[:status] ? { status: true } : not_exists
    end

    def check_existing_category_name
      if Category.find_by(name: @name, department_id: @department_id)
        return { status: false, error_message: I18n.t('categories.error.exists') }
      else
        return { status: true }
      end
    end

    def save_category
      @new_category = Category.new(name: @name, priority: @priority, department_id: @department_id)
      if @new_category.save
        { status: true }
      else
        { status: false, error_message: @new_category.errors.full_messages.join(", ") }
      end
    end
  end
end
