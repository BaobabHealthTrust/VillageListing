class NewsController < ApplicationController
	skip_before_filter :check_if_logged_in # we want news to be accessible even without being logged in
	
	def index
		@news = News.all.order('created_at desc')

		our_ip_address = request.remote_ip
		Dir.entries("../lastseennews").each { |file_name|
			if file_name.match(our_ip_address)
				File.open("../lastseennews/#{file_name}", "w"){|f|
					f.write(Time.now.to_s(:db))
				}
				break;
			end
		}

		render layout: false
	end
end
