require 'rails_helper'

describe 'dde_controller' do
	describe 'GET dde_authenticate' do
		it 'responds 200 status code' do
			expect(response.status).to eq(200)
		end
	end
end