class Ahoy::Store < Ahoy::DatabaseStore
end

# set to true for JavaScript tracking
Ahoy.api = true

# set protection to elements with no user-agents like bots
#Ahoy.server_side_visits = false

# better user agent parsing
Ahoy.user_agent_parser = :device_detector
