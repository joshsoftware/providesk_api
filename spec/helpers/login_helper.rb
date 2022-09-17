module LoginHelper
  def login_user
    user = FactoryBot.create(:user)
    @org = user.organization
    payload = { user_id: user.id, name: user.name, email: user.email, google_user_id: 1 }
    token = JsonWebToken.encode(payload)
    header 'Accept', 'application/vnd.providesk; version=1'
    header 'Authorization', token
  end
end
