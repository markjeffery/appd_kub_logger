# appd_kub_logger
Kubernetes Pod to push kubernetes events to AppDynamics Analaytics

This is a Ruby based pod that makes REST API calls to the Kubernetes Events API

Using service account (appdlogger)

http://kubernetes.io/docs/admin/authentication/

osxltmjeff:appd_kub_logger mark.jeffery$ kubectl create serviceaccount appdlogger
serviceaccount "appdlogger" created
osxltmjeff:appd_kub_logger mark.jeffery$ ls
Dockerfile		Gemfile			Gemfile.lock		README.md		postkubevents.rb
osxltmjeff:appd_kub_logger mark.jeffery$ kubectl get serviceaccounts appdlogger -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: 2016-10-20T20:30:33Z
  name: appdlogger
  namespace: default
  resourceVersion: "181996"
  selfLink: /api/v1/namespaces/default/serviceaccounts/appdlogger
  uid: 0cf15f79-9704-11e6-ab5a-16ff826b5ab3
secrets:
- name: appdlogger-token-pi1h3
osxltmjeff:appd_kub_logger mark.jeffery$ 


Using the GET /api/v1/events API

http://kubernetes.io/docs/api-reference/v1/operations/

Using a Ruby based docker image

https://hub.docker.com/_/ruby/

