module::Users::V1
  class Destroy
    def initialize(user_id)
      @user_id = user_id
    end 

    def call
      (check_user_existence && delete_user) ? { status: true } : { status: false }
    end

    def check_user_existence
      User.exists?(@user_id)
    end

    def delete_user
      if User.find(@user_id).destroy
        { status: true }
      else
        { status: false }
      end
    end
  end
end