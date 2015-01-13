require 'pry'

current_evaluations = 0
# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '10s', :first_in => 0 do |job|
  host = ENV['HOST']
  # points = [{x:1, y:4}, {x:2, y:27}, {x:3, y:6}]
  # send_event('burndown', points: points)
  year = 2015
  month = 01
  goal = 4000

  url = URI.parse("#{host}/dakar/burnup/evaluations?year=#{year}&month=#{month}&goal=#{goal}")
  http = Net::HTTP.new(url.host, url.port)
  response = http.request(Net::HTTP::Get.new(url.request_uri))

  # Convert to JSON
  j = JSON[response.body]

  raise RuntimeError, "JSON de resposta vazio #{j}" unless j
  
  done_effort_series = j["response"]["series"][1]["data"]

  raise RuntimeError, "Done Effort Series esta vazia #{done_effort_series}" unless done_effort_series

  percentage = (done_effort_series.last["y"].to_f / 500) * 100 
  send_event('burndown_evaluations', series: j["response"]["series"])
  send_event('evaluations_done', { value: percentage })

  # Wont create another job because PGConnect should not share threads
  last_evaluations = current_evaluations  
  url = URI.parse("#{host}/total_evaluations")
  http = Net::HTTP.new(url.host, url.port)
  response = http.request(Net::HTTP::Get.new(url.request_uri))

  # # Convert to JSON
  j = JSON[response.body]
  # print JSON[response.body]
  current_evaluations = j["value"]
  send_event('total_evaluations',  { current: current_evaluations, last: last_evaluations })  


end