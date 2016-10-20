#! /usr/local/bin/ruby
require 'rubygems'
require 'json'
require 'pp'
require 'net/http'
require 'open3'

# KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
# curl -sSk -H "Authorization: Bearer $KUBE_TOKEN"
# https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/default/events

# Read Kubernetes token

file = File.open("/var/run/secrets/kubernetes.io/serviceaccount/token")
contents = "Authorization: Bearer "
file.each {|line|
  contents << line
}

puts contents
