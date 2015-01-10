# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '30s', :first_in => 0 do |job|
  print "Extracting series data and constructing widget event message...\n"
  # points = [{x:1, y:4}, {x:2, y:27}, {x:3, y:6}]
  # send_event('burndown', points: points)
  year = 2015
  month = 01
  goal = 4000

  url = URI.parse("http://ninenine-stats.herokuapp.com/dakar/evaluations?year=#{year}&month=#{month}&goal=#{goal}")
  http = Net::HTTP.new(url.host, url.port)
  response = http.request(Net::HTTP::Get.new(url.request_uri))

  # Convert to JSON
  j = JSON[response.body]
  percentage = (j["response"]["series"][1]["data"].last["y"].to_f / 500) * 100

  send_event('burndown_evaluations', series: j["response"]["series"])
  send_event('evaluations_done', { value: percentage })
end