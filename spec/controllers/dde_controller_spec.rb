require 'rails_helper'

RSpec.describe DdeController do
	describe 'GET #dde_authenticate' do
		it 'responds with status 200 or 320' do
			get :dde_authenticate
			expect(response.status).to be_between(200, 320).inclusive
		end
	end
end