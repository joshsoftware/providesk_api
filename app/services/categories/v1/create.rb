module Categories::V1
  class Create
    
    def initialize(categories, current_user)
      @name = categories[:name]
      @priority = categories[:priority].to_i
      @department_id = categories[:department_id]
      @current_user = current_user
    end

    def call
      not_exits = !check_existing_category_name && save_category
      not_exits ? { status: true } : { status: false } 
    end

    def check_existing_category_name
      Category.find_by(name: @name)
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