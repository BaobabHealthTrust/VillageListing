class NewsController < ApplicationController
	skip_before_filter :check_if_logged_in # we want news to be accessible even without being logged in
	after_action :track_action
	
	def index
		@news = News.all.order('created_at desc')

		render layout: false
	end

	def viewed_article
		ahoy.track "Viewed article", params
	end

	protected

	def track_action
	  ahoy.track "News visit", request.path_parameters
	end
end
