resource "aws_launch_template" "spots" {
  name_prefix = format("%s-spots", var.project_name)
  image_id    = var.nodes_ami

  instance_type = var.node_instance_type

  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.30"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.main.name
  }

  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.node_volume_size
      volume_type = var.node_volume_type
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = format("%s-on-demand", var.project_name)
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/user-data.tpl", {
    CLUSTER_NAME = var.project_name
  }))
}