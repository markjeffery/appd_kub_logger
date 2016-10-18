# appd_kub_logger
Kubernetes Pod to push kubernetes events to AppDynamics Analaytics

This is a Ruby based pod that makes REST API calls to the Kubernetes Events API

Using service account (appdlogger)

http://kubernetes.io/docs/admin/authentication/

Using the GET /api/v1/events API

http://kubernetes.io/docs/api-reference/v1/operations/

Using a Ruby based docker image

https://hub.docker.com/_/ruby/

