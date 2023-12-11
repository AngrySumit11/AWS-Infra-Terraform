resource "aws_launch_template" "course1" {
  name = "${var.primary_name}-${var.environment}-${var.service}-lt"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.ec2_root_volume_size
    }
  }
  
  key_name = var.ec2_key_name
  instance_type = var.ec2_instance_type
  vpc_security_group_ids = [
    aws_security_group.course1.id,
    var.course1_extra_sg
  ]
  image_id  = var.ec2_ami[data.aws_region.current.name]
  user_data = data.template_cloudinit_config.cloud-init.rendered
  placement {
    tenancy = "default"
  }
  monitoring {
    enabled = true
  }
  iam_instance_profile {
    name = var.create_course1_iam ? aws_iam_instance_profile.course1[0].name : format("%s-%s", var.service, var.environment)
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = "${var.primary_name}-${var.environment}-${var.service}-node"
      },
      var.tags
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      {
        Name = "${var.primary_name}-${var.environment}-${var.service}-node"
      },
      var.tags
    )
  }

  //  tag_specifications {
  //    resource_type = "spot-instances-request"
  //    tags = merge(
  //      {
  //        Name = "${var.primary_name}-${var.environment}-${var.service}-node"
  //      },
  //      var.tags
  //    )
  //  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Name" = "${var.primary_name}-${var.environment}-${var.service}-node"
  }
}

resource "aws_autoscaling_group" "course1" {
  name                = format("%s-%s-%s-node", var.primary_name, var.environment, var.service)
  vpc_zone_identifier = data.aws_subnet_ids.private_gateway.ids

  launch_template {
    id      = aws_launch_template.course1.id
    version = "$Latest"
  }

  desired_capacity          = var.asg_desired_capacity
  force_delete              = false
  health_check_grace_period = var.asg_health_check_grace_period
  health_check_type         = "ELB"
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size

  target_group_arns = compact(
    concat(
      aws_lb_target_group.external.*.arn,
      aws_lb_target_group.internal.*.arn,
      aws_lb_target_group.admin.*.arn,
      aws_lb_target_group.manager.*.arn,
      aws_lb_target_group.portal-gui.*.arn,
      aws_lb_target_group.portal.*.arn
    )
  )

  tag {
    key                 = "Name"
    value               = format("%s-%s-%s-node", var.primary_name, var.environment, var.service)
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
  tag {
    key                 = "Description"
    value               = var.description
    propagate_at_launch = true
  }
  tag {
    key                 = "Service"
    value               = var.service
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  depends_on = [
    aws_db_instance.course1,
    aws_rds_cluster.course1
  ]
}
