class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :department_id, :role

  def role
    object.role.name
  end
end
