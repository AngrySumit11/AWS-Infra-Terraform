
resource "datadog_monitor" "Containerrunningoutofmemoryhasrunoutofmemory" {
  provider    = datadog.integrate
  message = "The container {{container_name.name}} under the cluster {{kube_cluster_name.name}} is running out of memory. \n\nPlease look at it @slack-datadog-course3-infra-alerts"
  monitor_thresholds {
    critical = "0.99"
    warning  = "0.95"
  }
  name                = "Container running out of memory/has run out of memory"
  new_group_delay     = 60
  notify_audit        = false
  notify_no_data      = true
  query               = "max(last_5m):avg:kubernetes.memory.usage_pct{cluster_name:course3*} by {container_name,kube_cluster_name} >= 0.99"
  require_full_window = false
  tags                = ["integration:kubernetes", "env:course3-prod"]
  type                = "query alert"
  restricted_roles     = ["467bc836-497f-11ed-bf91-da7ad0900002"]
}

resource "datadog_monitor" "course3-prod-pod-down" {
  provider    = datadog.integrate
  message = "Pod {{pod_name.name}}  under {{kube_cluster_name.name}} cluster is in {{pod_phase.name}}  state. Please check the deployment associated to it. \n@slack-datadog-course3-infra-alerts"
  monitor_thresholds {
    critical = "1"
    critical_recovery = "0"
  }
  name                = "Pod {{pod_name.name}} under the course3 cluster {{kube_cluster_name.name}} is in {{pod_phase.name}} state"
  new_group_delay     = 60
  no_data_timeframe   = 5
  notify_audit        = true
  notify_no_data       = true
  priority            = 2
  query               = "avg(last_5m):avg:kubernetes_state.pod.status_phase{cluster_name:* AND pod_phase:failed OR pod_phase:pending} by {kube_cluster_name,pod_phase,pod_name} >= 1"
  require_full_window = false
  tags                = ["integration:kubernetes", "env:course3-prod"]
  type                = "query alert"
  restricted_roles     = ["467bc836-497f-11ed-bf91-da7ad0900002"]
}