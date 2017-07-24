class NewsController < ApplicationController
	skip_before_filter :check_if_logged_in # we want news to be accessible even without being logged in
	
	def index
		render layout: false
	end
end
