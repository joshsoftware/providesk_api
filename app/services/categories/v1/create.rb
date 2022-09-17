module Categories::V1
  class Create
    
    def initialize(categories, current_user)
      @name = categories[:name]
      @priority = categories[:priority].to_i
      @department_id = categories[:department_id]
      @current_user = current_user
    end

    def call
      check_existing_category_name && save_category
    end

    def check_existing_category_name
      return { status: false } if Category.find_by(name: @name)
      true
    end

    def save_category
      @new_category = Category.new(name: @name, priority: @priority, department_id: @department_id)
      if @new_category.save
        { status: true }.as_json
      else
        { status: false, error_message: @new_category.errors.full_messages.join(", ") }.as_json
      end
    end
  end
end