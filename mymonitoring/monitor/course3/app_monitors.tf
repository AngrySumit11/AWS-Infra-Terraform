

resource "datadog_monitor" "app-error-alert" {
  provider    = datadog.integrate
  for_each    = toset(var.oncall_app_service_list)

  message = "${each.value} errors deviated too much from its usual value.\n@slack-datadog-course3-app-alerts @pagerduty-Global-App-alert @pagerduty-acknowledge"
  monitor_thresholds {
    critical = "5"
 }
  name                = "Service ${each.value} has an abnormal change in errors on env:prod"
  notify_audit        = true
  notify_no_data      = false
  no_data_timeframe   = 0
  query               = "avg(last_5m):sum:trace.fastapi.request.errors{env:prod,service:${each.value}}.as_rate() >= 5"
  require_full_window = false
  type                = "query alert"
  restricted_roles    = ["467bc836-497f-11ed-bf91-da7ad0900002"]
  tags                = ["env:course3-prod","service:${each.value}", "monitor_type:error_check"]
  priority            = 1
}

resource "datadog_monitor" "app-endpoint-alert" {
  provider            = datadog.integrate
  for_each = var.oncall_service_endpoints

  include_tags        = false
  message = "The service health check is failing.\n\nEndpoint:  ${each.value} \n\n@slack-datadog-course3-app-alerts\n@pagerduty-Global-App-alert \n@pagerduty-acknowledge"
  monitor_thresholds {
    critical = "2"
    ok       = "1"
    warning  = "1"
    unknown  = "2"
 }
  name                = "Not able to reach endpoint for ${each.key} service"
  notify_audit        = true
  notify_no_data      = true
  no_data_timeframe   = 5
  query               = "\"http.can_connect\".over(\"instance:${each.key}\",\"url:${each.value}\").by(\"*\").last(3).count_by_status()"
  require_full_window = false
  type                = "service check"
  restricted_roles    = ["467bc836-497f-11ed-bf91-da7ad0900002"]
  tags                = ["env:course3-prod", "monitor_type:endpoint_check"]
  priority            = 1
}

