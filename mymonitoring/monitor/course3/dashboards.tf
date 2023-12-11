resource "datadog_dashboard" "apps_dashboard" {
  provider     = datadog.integrate
  title        = "Global Apps Dashboard"
  description  = "This dashboard keeps track of various metrics and logs associated to the applications handled by the global team"
  layout_type  = "ordered"
  reflow_type  = "fixed"
  
  template_variable {
            available_values = [
                "app1",
                "app2",
                "app3",
            ]   
            default          = "*"   
            defaults         = []   
            name             = "App_name"   
            prefix           = "service"   
        }

        template_variable_preset {
            name = "App Dashboard"   

            template_variable {
                name   = "App_name"   
                value  = ""   
                   
            }
            template_variable {
                name   = "instance"   
                value  = ""   
                  
            }
        }

        widget {
          
            query_value_definition {
                autoscale   = true   
                precision   = 2   
                title       = "Service status"   
                title_align = "left"   
                title_size  = "16"   

                request {

                    conditional_formats {
                        comparator = ">"   
                        hide_value = false   
                        palette    = "white_on_green"   
                        value      = 0   
                    }

                    formula {
                        formula_expression = "query1"   
                    }

                    query {

                        metric_query {
                            aggregator  = "avg"   
                            data_source = "metrics"   
                            name        = "query1"   
                            query       = "avg:kubernetes_state.container.running{$App_name}"   
                        }
                    }
                }

                timeseries_background {
                    type = "area"   
                }
            }

            widget_layout {
                height          = 2   
                is_column_break = false   
                width           = 12   
                x               = 0   
                y               = 0   
            }
        }
        widget {

            query_table_definition {
                title       = "Pod status"   
                title_align = "left"   
                title_size  = "16"   

                request {
                    cell_display_mode = []   
                    limit             = 0   

                    formula {
                        formula_expression = "query1"   

                        limit {
                            count = 500   
                            order = "desc"   
                        }
                    }

                    query {

                        metric_query {
                            aggregator  = "avg"   
                            data_source = "metrics"   
                            name        = "query1"   
                            query       = "max:kubernetes_state.pod.status_phase{$App_name} by {kube_deployment,node,pod_phase,pod_name}"   
                        }
                    }
                }
            }

            widget_layout {
                height          = 2   
                is_column_break = false   
                width           = 12   
                x               = 0   
                y               = 2   
            }
        }
        widget {

            timeseries_definition {
                legend_columns = [
                    "avg",
                    "max",
                    "min",
                    "sum",
                    "value",
                ]   
                legend_layout  = "auto"   
                show_legend    = false   
                title          = "API hits vs errors"   
                title_align    = "left"   
                title_size     = "16"   

                request {
                    display_type   = "line"   
                    on_right_yaxis = false   

                    formula {
                        formula_expression = "query1"   
                    }
                    formula {
                        formula_expression = "query2"   
                    }

                    query {

                        metric_query {
                            data_source = "metrics"   
                            name        = "query1"   
                            query       = "max:trace.fastapi.request.hits{$App_name}.as_count()"   
                        }
                    }
                    query {

                        metric_query {
                            data_source = "metrics"   
                            name        = "query2"   
                            query       = "max:trace.fastapi.request.errors{$App_name}.as_count()"   
                        }
                    }

                    style {
                        line_type  = "solid"   
                        line_width = "normal"   
                        palette    = "dog_classic"   
                    }
                }
            }

            widget_layout {
                height          = 4   
                is_column_break = false   
                width           = 6   
                x               = 0   
                y               = 4   
            }
        }
        widget {
        
            timeseries_definition {
                legend_columns = [
                    "avg",
                    "max",
                    "min",
                    "sum",
                    "value",
                ]   
                legend_layout  = "auto"   
                show_legend    = false   
                title          = "API request latency"   
                title_align    = "left"   
                title_size     = "16"   

                request {
                    display_type   = "line"   
                    on_right_yaxis = false   

                    formula {
                        formula_expression = "query1"   
                    }
                    formula {
                        formula_expression = "query2"   
                    }
                    formula {
                        formula_expression = "query3"   
                    }
                    formula {
                        formula_expression = "query4"   
                    }
                    formula {
                        formula_expression = "query5"   
                    }

                    query {

                        metric_query {
                            data_source = "metrics"   
                            name        = "query1"   
                            query       = "max:trace.fastapi.request{$App_name} by {service}"   
                        }
                    }
                    query {

                        metric_query {
                            data_source = "metrics"   
                            name        = "query2"   
                            query       = "p99:trace.fastapi.request{$App_name} by {service}"   
                        }
                    }
                    query {

                        metric_query {
                            data_source = "metrics"   
                            name        = "query3"   
                            query       = "p95:trace.fastapi.request{$App_name} by {service}"   
                        }
                    }
                    query {

                        metric_query {
                            data_source = "metrics"   
                            name        = "query4"   
                            query       = "p75:trace.fastapi.request{$App_name} by {service}"   
                        }
                    }
                    query {

                        metric_query {
                            data_source = "metrics"   
                            name        = "query5"   
                            query       = "p50:trace.fastapi.request{$App_name} by {service}"   
                        }
                    }

                    style {
                        line_type  = "solid"   
                        line_width = "normal"   
                        palette    = "dog_classic"   
                    }
                }
            }

            widget_layout {
                height          = 4   
                is_column_break = false   
                width           = 6   
                x               = 6   
                y               = 4   
            }
        }
        widget {  

            timeseries_definition {
                legend_columns = [
                    "avg",
                    "max",
                    "min",
                    "sum",
                    "value",
                ]   
                legend_layout  = "auto"   
                show_legend    = true   
                title          = "Average memory usage per container"   
                title_align    = "left"   
                title_size     = "16"   

                request {
                    display_type   = "line"   
                    on_right_yaxis = false   

                    formula {
                        formula_expression = "query1"   
                    }

                    query {

                        metric_query {
                            data_source = "metrics"   
                            name        = "query1"   
                            query       = "avg:kubernetes.memory.usage_pct{$App_name} by {container_name,kube_cluster_name}"   
                        }
                    }

                    style {
                        palette = "classic"   
                    }
                }
            }

            widget_layout {
                height          = 4   
                is_column_break = false   
                width           = 6   
                x               = 0   
                y               = 8   
            }
        }
        widget {

            timeseries_definition {
                legend_columns = [
                    "avg",
                    "max",
                    "min",
                    "sum",
                    "value",
                ]   
                legend_layout  = "auto"   
                show_legend    = true   
                title          = "Average container CPU utilisation percentage"   
                title_align    = "left"   
                title_size     = "16"   

                request {
                    display_type   = "line"   
                    on_right_yaxis = false   

                    formula {
                        formula_expression = "(query1 / query2) * 100"   
                    }

                    query {

                        metric_query {
                            data_source = "metrics"   
                            name        = "query1"   
                            query       = "avg:container.cpu.user{$App_name}"   
                        }
                    }
                    query {

                        metric_query {
                            data_source = "metrics"   
                            name        = "query2"   
                            query       = "avg:container.cpu.limit{$App_name}"   
                        }
                    }

                    style {
                        line_type  = "solid"   
                        line_width = "normal"   
                        palette    = "dog_classic"   
                    }
                }
            }

            widget_layout {
                height          = 4   
                is_column_break = false   
                width           = 6   
                x               = 6   
                y               = 8   
            }
        }
        widget {

            list_stream_definition {
                title       = "API log Stream"   
                title_align = "left"   
                title_size  = "16"   

                request {
                    response_format = "event_list"   

                    columns {
                        field = "status_line"   
                        width = "auto"   
                    }
                    columns {
                        field = "timestamp"   
                        width = "auto"   
                    }
                    columns {
                        field = "host"   
                        width = "auto"   
                    }
                    columns {
                        field = "service"   
                        width = "auto"   
                    }
                    columns {
                        field = "content"   
                        width = "compact"   
                    }

                    query {
                        data_source  = "logs_stream"   
                        indexes      = []   
                        query_string = "$App_name"   
                        storage      = "hot"   
                    }
                }
            }

            widget_layout {
                height          = 5   
                is_column_break = false   
                width           = 12   
                x               = 0   
                y               = 12   
            }
        }
        widget {

            list_stream_definition {
                title       = "API Event Stream"   
                title_align = "left"   
                title_size  = "16"   

                request {
                    response_format = "event_list"   
                    
                     columns {
                        field = "source"   
                        width = "auto"   
                    }
                    columns {
                        field = "message"   
                        width = "auto"   
                    }

                    query {
                        data_source  = "event_stream"   
                        event_size   = "l"   
                        indexes      = []   
                        query_string = "$App_name"   
                    }
                }
            }

            widget_layout {
                height          = 4   
                is_column_break = false   
                width           = 12   
                x               = 0   
                y               = 17   
            }
        }

  
}