

module "eks"{
  source = "terraform-aws-modules/eks/aws"
  version = "19.16.0"
  cluster_name    = "cluster-terraform"
  cluster_version = "1.27" 
  
  vpc_id = "vpc-02e33fd5f59a7975e"
  subnet_ids = ["subnet-095839b70040bdefd","subnet-04032108dea94469e","subnet-0f9da8086dda7b36e","subnet-094e1370f21843f0a","subnet-0c55fa5cd3cf77614", "subnet-048b15ab9dbd7ae53"]
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = false

  
  cluster_addons = {
    coredns = {
      preserve = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    } 
    aws-ebs-csi-driver = { 
      most_recent = true
    }
  }

self_managed_node_group_defaults = {
    instance_type                          = "t3.large"
    update_launch_template_default_version = true
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  self_managed_node_groups = {
    one = {
      name         = "self-1"
      max_size     = 5
      desired_size = 2

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 10
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          {
            instance_type     = "t3.large"
            weighted_capacity = "1"
          },
          {
            instance_type     = "t3.medium"
            weighted_capacity = "2"
          },
        ]
      }
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    alpha = {
        min_size     = 1
        max_size     = 10
        desired_size = 2
        instance_types = ["t3.medium"]
        capacity_type = "SPOT"
        tags = {
          "dialog-node/role" = "alpha"
        }
        labels = {
        "dialog-node/role" = "alpha"
      }
        
    }
    master = {
      min_size     = 1
      max_size     = 10
      desired_size = 2
      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
      labels = {
        "dialog-node/role" = "master"
      }
      tags = {
        "dialog-node/role" = "master"
      }
    }
    
  }
}

output "eks" {
  value = module.eks.*
}
