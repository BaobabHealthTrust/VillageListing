VILLAGE LISTING
---------------

DESCRIPTION
-----------

Application built in Ruby on Rails (RoR) to be used for registration of residents per village under TA.

GETTING APPLICATION
-------------------

Get the application from github either by downloading it as a Zip file and extracting it 
or by cloning it into /var/www/

	By Clonning;

	https:
	
		https://github.com/BaobabHealthTrust/VillageListing.git

	ssh:
	
		git@github.com:BaobabHealthTrust/VillageListing.git

RUBY VERSION
------------

Ruby 2.2.2

	Verify that your Ruby Version Manager has ruby 2.2.2. activated for this application

Run

	bundle install

SYSTEM DEPENDENCIES
-------------------
	
1. Village Listing User Management. 

	Village Listing depends on Village Listing user Management (development branch) for villages,
	districts, tas, and users. Make sure you have this application running alongside. 
	For more info, clone as a separate application from;

		https:
			
			https://github.com/BaobabHealthTrust/VillageListingUserManagement.git

		ssh:

			git@github.com:BaobabHealthTrust/VillageListingUserManagement.git

	and follow it's README. (Make sure you are in the 'development' branch)

2. DDE3.0

	Village Listing depends on DDE 2 (village_listing_api branch) for Sites, and National ID allocation.
	Make sure you have this application running alongside.

CONFIGURATION
-------------

1. globals.yml
	
	In the config directory, configure the globals.yml by renaming or copying the globals.yml.example to globals.yml

	Open the file with your favourite editor and modify line 25 specifying the user_mgmt_url to the url which 
	Village Listing User Management is running on. 

2. dde_connection.yml

	In the config directory, configure the dde_connection.yml by renaming or copying the dde_connection.yml.example to dde_connection.yml 

	Open the file with your favourite editor and set the following attributes;

		dde_server, dde_username, dde_password, site_code (if there is need to change the defaults)

	dde_server is the url with port on which DDE 2 Application is running on. 
	dde_username and dde_password is the username and password respectively to which couchdb is configured.
	The site code should be the code for the site at which the application is being developed for.

		eg. MTA for Mtema

RUN APPLICATION !!!
------------------
Yeay...!!! We all Good. :-) 
