
##################################################################################
#                                                                                #
# Created by: Jacob Mziya (BHT Software Developer)                               #
# Description: To migrate Mzumazi data into Mzumazi 1 and 2 respectively         #
# Created on: February 09th, 2018                                                #
# Plugins: roo                                                                   #
#                                                                                #
##################################################################################

require 'roo'

def migrate_mzumazi
	#xlsx = Roo::Spreadsheet.open("#{Rails.root}/app/assets/data/mzumazi_1_and_2.xlsx")
	xlsx = Roo::Excelx.new("#{Rails.root}/app/assets/data/mzumazi_1_and_2.xlsx")
	i = 0
	
	xlsx.each_row_streaming(pad_cells: true) do |row|
		# Array of Excelx::Cell objects
		i = i + 1
		
		# send details as params to update
		# find person_id
		###############################################
		
		Kernel.system ('mkdir lib/migration_logs')
		log_text = "Skipped #{row[5].value}, #{row[4].value} :Invalid Date of Birth format."
		log_file = "#{Rails.root}/lib/migration_logs/mzumazi_migration.txt"
		command = "echo #{log_text} >> #{log_file}"
		if Kernel.system (command)
			Kernel.system ("echo #{log_text}")
		end
		next
		
		return 'Creating data successfully completed.' if row[0].nil?
	end
end

migrate_mzumazi