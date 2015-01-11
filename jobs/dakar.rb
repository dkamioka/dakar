current_evaluations = 0
# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '30m', :first_in => 0 do |job|
  last_evaluations = current_evaluations  
  url = URI.parse("http://ninenine-stats.herokuapp.com/total_evaluations")
  http = Net::HTTP.new(url.host, url.port)
  response = http.request(Net::HTTP::Get.new(url.request_uri))

  # # Convert to JSON
  # j = JSON[response.body]
  print JSON[response.body]
  # current_evaluations = 2
  send_event('total_evaluations',  { current: current_evaluations, last: last_evaluations })  

end