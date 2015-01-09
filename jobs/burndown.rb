# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '30s', :first_in => 0 do |job|
  print "Extracting series data and constructing widget event message...\n"
  # points = [{x:1, y:4}, {x:2, y:27}, {x:3, y:6}]
  # send_event('burndown', points: points)
  url = URI.parse("http://ninenine-stats.herokuapp.com/dakar/evaluations?year=2015&month=1&goal=4000")
  http = Net::HTTP.new(url.host, url.port)
  response = http.request(Net::HTTP::Get.new(url.request_uri))

  # Convert to JSON
  j = JSON[response.body]


  send_event('burndown_evaluations', series: j["series"])
  send_event('evaluations_done', { value: (j["series"][1]["data"].last["y"].to_i / 4000) * 100})
end