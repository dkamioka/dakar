require 'pry'

current_evaluations = 0
current_opportunities = 0
# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '10s', :first_in => 0 do |job|

################## EVALUATIONS BELOW ##################  

  host = ENV['HOST']
  begin
    # points = [{x:1, y:4}, {x:2, y:27}, {x:3, y:6}]
    # send_event('burndown', points: points)
    evaluations_year = 2015
    evaluations_month = 01
    evaluations_goal = 4000

    url = URI.parse("#{host}/dakar/burnup/evaluations?year=#{evaluations_year}&month=#{evaluations_month}&goal=#{evaluations_goal}")
    http = Net::HTTP.new(url.host, url.port)
    response = http.request(Net::HTTP::Get.new(url.request_uri))

    # Convert to JSON
    j = JSON[response.body]

    raise RuntimeError, "JSON de resposta vazio #{j}" unless j
    
    done_effort_series = j["response"]["series"][1]["data"]

    raise RuntimeError, "Done Effort Series esta vazia #{done_effort_series}" unless done_effort_series

    percentage = (done_effort_series.last["y"].to_f / 500) * 100 
    send_event('burndown_evaluations', {series: j["response"]["series"], displayedValue: done_effort_series.last["y"].to_f})
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

################## OPPORTUNITIES BELOW ##################
  begin
    opportunities_year = 2015
    opportunities_month = 01
    opportunities_goal = 400

    url = URI.parse("#{host}/dakar/burnup/opportunities?year=#{opportunities_year}&month=#{opportunities_month}&goal=#{opportunities_goal}")
    http = Net::HTTP.new(url.host, url.port)
    response = http.request(Net::HTTP::Get.new(url.request_uri))

    # Convert to JSON
    j = JSON[response.body]

    raise RuntimeError, "JSON de resposta vazio #{j}" unless j
    
    done_effort_series = j["response"]["series"][1]["data"]

    raise RuntimeError, "Done Effort Series esta vazia #{done_effort_series}" unless done_effort_series

    percentage = (done_effort_series.last["y"].to_f / 500) * 100 
    send_event('burnup_opportunities', {series: j["response"]["series"], displayedValue: done_effort_series.last["y"].to_f})
    send_event('opportunities_done', { value: percentage })

    # Wont create another job because PGConnect should not share threads
    last_opportunities = current_opportunities  
    url = URI.parse("#{host}/total_opportunities")
    http = Net::HTTP.new(url.host, url.port)
    response = http.request(Net::HTTP::Get.new(url.request_uri))

    # # Convert to JSON
    j = JSON[response.body]
    # print JSON[response.body]
    current_opportunities = j["value"]  
    send_event('total_opportunities', { current: current_opportunities, last: last_opportunities })  
  end

end