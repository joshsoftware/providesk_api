module Users::V1
  class Show
    def initialize(user_id)
      @user_id = user_id
    end

    def call
      if User.exists?(@user_id.to_i)
        { status: true, user_data: User.find(@user_id.to_i).as_json }
      else
        { status: false }
      end
    end

  end
end