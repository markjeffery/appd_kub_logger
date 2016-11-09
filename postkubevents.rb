#! /usr/local/bin/ruby
require 'rubygems'
require 'json'
require 'pp'
require 'net/https'

def transform_hash(oldhash)
    newhash = Hash.new
    if oldhash["kind"].eql?("Event") then
        newhash["name"] = oldhash["metadata"]["name"]
        newhash["namespace"] = oldhash["metadata"]["namespace"]
        newhash["selfLink"] = oldhash["metadata"]["selflink"]
        newhash["uid"] = oldhash["metadata"]["uid"]
        newhash["resourceVersion"] = oldhash["metadata"]["resourceVersion"]
        newhash["creationTimestamp"] = oldhash["metadata"]["creationTimestamp"]
    else
        newhash["name"] = oldhash["name"]
        newhash["namespace"] = oldhash["namespace"]
        newhash["selfLink"] = oldhash["selflink"]
        newhash["uid"] = oldhash["uid"]
        newhash["resourceVersion"] = oldhash["resourceVersion"]
        newhash["creationTimestamp"] = oldhash["creationTimestamp"]
    end
    # Same for event list and single event */
    newhash["kind"] = oldhash["kind"]
    newhash["apiVersion"] = oldhash["apiVersion"]
    # Three more items inside involved Object - namespace, apiVersion, resourceVersion, fieldPath
    newhash["reason"] = oldhash["reason"]
    newhash["message"] = oldhash["message"]
    newhash["eventTimestamp"] = oldhash["firstTimestamp"]
    newhash["lastTimestamp"] = oldhash["lastTimestamp"]
    newhash["count"] = oldhash["count"]
    newhash["type"] = oldhash["type"]
    if oldhash.key?("involvedObject") then
        newhash["involvedObjectKind"] = oldhash["involvedObject"]["kind"]
        newhash["involvedObjectName"] = oldhash["involvedObject"]["name"]
        newhash["involvedObjectUid"] = oldhash["involvedObject"]["uid"]
    end
    if oldhash.key?("source") then
        newhash["sourceComponent"] = oldhash["source"]["component"]
        newhash["sourceHost"] = oldhash["source"]["host"]
    end
    # Replace nil values with 0 or ""
    newhash.keys.each do |key|
        if key.eql?("count") then
            newhash[key] = 0 if newhash[key].nil?
        else
            newhash[key] = '' if newhash[key].nil?
        end
    end
    return newhash
end

def send_events(parsed)
    outarr = Array.new
    if parsed["kind"].eql?("EventList") then
        resourceVersion = parsed["metadata"]["resourceVersion"]
        puts "Picked up Resource Version #{resourceVersion}"
        puts "Parsing #{parsed["items"].size} items"
        parsed["items"].each do |ev|
            outhash = transform_hash(ev)
            outarr.push(outhash)
        end
    else
        resourceVersion=""
        puts "Only picked up 1 item - I dont think this should happen now"
        outhash = transform_hash(parsed)
        outarr.push(outhash)
    end

    if outarr.size > 0 then
        url = "http://192.168.99.1:9080/events/publish/KubernetesEvents"
        uri = URI.parse(url)

        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.path,
            initheader = {
                "Content-type" => "application/vnd.appd.events+json;v=1",
                "X-Events-API-AccountName" => "customer1_dafe513b-048d-4366-bba3-c186743bf418",
                "X-Events-API-Key" => "3ae6226d-899d-4d88-a60c-04a19355d721"
            })
        request.body = outarr.to_json

        puts request.body

        res = http.request(request)

        puts "Response #{res.code} #{res.message}: #{res.body}"
    end

    return resourceVersion
end

resourceVersion=""
file = File.open("/var/run/secrets/kubernetes.io/serviceaccount/token")
contents = "Bearer "
file.each {|line|
  contents << line
}

while true do
    host = ENV["KUBERNETES_SERVICE_HOST"]
    port = ENV["KUBERNETES_PORT_443_TCP_PORT"]

    if (resourceVersion.length > 0) then
        url = "https://#{host}:#{port}/api/v1/watch/namespaces/default/events?resourceVersion=#{resourceVersion}"
    else
        url = "https://#{host}:#{port}/api/v1/namespaces/default/events"
    end

    puts "URL is #{url}"
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    # I will sort this out!
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.path,
    initheader = {
        "Authorization" => contents
    })

    
    res = http.request(request)

    puts "Response #{res.code} #{res.message}: #{res.body}"

    resourceVersion = send_events(JSON.parse(res.body))
end