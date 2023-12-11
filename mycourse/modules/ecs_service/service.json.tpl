[
  {
    "name": "${c_name}",
    %{ if repo_secret != "" }
    "repositoryCredentials": {
      "credentialsParameter": "${repo_secret}"
    },
    %{ endif }
    "image": "${image}",
    "essential": true,
    "networkMode": "${network_mode}",
    %{ if c_port != 0 }
    "portMappings": [
      {
        "containerPort": ${c_port},
        "protocol": "tcp"
      }
      %{ if expose_ssh_port }
      ,{
        "containerPort": 2222,
        "protocol": "tcp"
      }
      %{ endif }
    ],
    %{ endif }
    "environment": ${jsonencode(environment)},
    "secrets": ${jsonencode(secrets)},
    %{ if length(entrypoint) > 0 }
    "entryPoint": ${jsonencode(entrypoint)},
    %{ endif }
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group_name}",
        "awslogs-region": "ap-southeast-1",
        "awslogs-stream-prefix": "${log_stream_prefix}"
      }
    }
  }
]