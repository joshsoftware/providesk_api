
require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Organizations' do
  let!(:organization) { FactoryBot.create(:organization, name: "google", domain: ["gmail.com"]) }
  let!(:role) { FactoryBot.create(:role, name: 'super admin')}
	let!(:user) { FactoryBot.create(:user, role_id: role.id) }
  post '/organizations' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
		end
		context '200' do
      example 'Organization created successfully' do
        do_request({"organization": {
					"name": "Josh",
          "domain": ["joshsoftware.com", "joshdigital.com"]
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["message"]).to eq(I18n.t('organizations.success.create'))
      end
    end

    context '422' do
      example 'Unable to create organization due to already existing name' do
        do_request({"organization": {
					"name": "google",
          "domain": ["gmail.com"]
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('organizations.error.create'))
        expect(response_data["errors"]). to eq("This name has already been taken")
      end

      example 'Unable to create organization due to blank name' do
        do_request({"organization": {
          "domain": ["joshsoftware.com", "joshdigital.com"]
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('organizations.error.create'))
        expect(response_data["errors"]).to eq("Name can't be blank")
      end

      example 'Unable to create organization due to invalid params' do
        do_request({"organization": {
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('organizations.error.invalid_params'))
      end
    end
  end
end