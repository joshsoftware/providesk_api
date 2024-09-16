module Categories::V1
  class Create
    def initialize(categories)
      @name = categories[:name]
      @priority = categories[:priority].to_i
      @department_id = categories[:department_id]
      @sla_unit = categories[:sla_unit].to_i
      @sla_duration_type = categories[:sla_duration_type]&.downcase
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
      @new_category = Category.new(name: @name, priority: @priority, department_id: @department_id,
                                   sla_unit: @sla_unit, sla_duration_type: @sla_duration_type,
                                   duration_in_hours: set_duration_in_hours)
      if @new_category.save
        { status: true }
      else
        { status: false, error_message: @new_category.errors.full_messages.join(", ") }
      end
    end

    private

    def set_duration_in_hours
      case @sla_duration_type
      when 'hours'
        return @sla_unit
      when 'days'
        return @sla_unit*24
      end
    end
  end
end
