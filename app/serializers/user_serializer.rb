class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :department_id, :role, :category_id

  def role
    object.role.name
  end

  def category_id
    object.user_categories.pluck(:category_id)
  end
end
