class NewsController < ApplicationController
	def index
		if request.post?
			raise params.inspect
		end
		render layout: false
	end
end
