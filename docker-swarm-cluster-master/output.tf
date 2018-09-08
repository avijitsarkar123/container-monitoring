# data "aws_instances" "docker-swarm-cluster-master-asg" {
#   instance_tags {
#     Name = "docker-swarm-cluster-master"
#   }
# }
#
# output "private-ips" {
#   depends_on = ["docker-swarm-cluster-master-asg"]
#   value      = "${data.aws_instances.docker-swarm-cluster-master-asg.private_ips}"
# }

