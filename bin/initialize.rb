def start
  villages = ["Mtema", "Nchazime", "Mbalani", "Konkha", "Kalulu", "Kambulire 1", "Kholongo", "Nsanda",
            "Mphonde", "Taiza", "Kambira", "Mmaso", "Chagamba 1", "Kabzyoko", "Kacheche", "Matchakaza",
            "Masumba", "Kamadzi", "Mutu", "Pheleni", "Nzumazi", "Nkhadani 2", "Malenga", "Mankhwazi",
            "Thandaza", "Kaning’a", "Chikamba", "Maselero", "Mdzoole", "Mbewa", "Nkhanamba",
            "Nkhadani 1", "Mawanda", "Kabwabwa", "Chiyenda Nchiwanda", "Mfuti", "Mbalame",
            "Dongolosi", "Bwalo 1", "Ndalama", "Mseteza", "Chikolokoto", "Mazira",
            "Mphambu", "Bwatha", "Misewu", "Chaonya", "Nkhonkha", "Kambulire 2", "Nkhuchi",
            "Kafutwe", "Kamphinga", "Chitawa", "Waya Kunseche",
            "Kuthengo", "Fainda", "Chisompha", "Mchazime", "Chizele", "Biwi", "Maole", "Chakale",
            "Mwaza", "Tonde", "Chizumba", "Mgwadula", "Mtema 2", "Mbulachina", "Ngoza", "Mkupeta",
            "Bwalo 2", "Undi", "Chimphepo Chalasa", "Chitululu", "Mchena", "Suntche 2", "Suntche 1",
            "Chule 2", "Chule 1", "Kazinkambani", "Chidalanda", "Mndele", "Kanyoza", "Kalundu", "Mzingo", "Chalasa", "Mtema 1"]

  district = "lilongwe"
  ta = "mtema"

  if !File.exist?("#{Rails.root}/log/lastseen")
    Dir.mkdir "#{Rails.root}/log/lastseen"
  end

  if !File.exist?("../lastseennews")
    Dir.mkdir "../lastseennews"
  end

  villages.each_with_index do |village, i|
    next if i > 45
    district = district.downcase.gsub(/\s+/, '_').downcase
    ta = ta.downcase.gsub(/\s+/, '_').downcase
    village = village.downcase.gsub(/\s+/, '_').downcase
    site = "#{district}__#{ta}__#{village}"
    FileUtils.touch "#{Rails.root}/log/lastseen/#{site}"
  end

end

puts "Start init"
start
puts "End init"
