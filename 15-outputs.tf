output "splunk-lb-dns" {
  value = "http://${aws_lb.splunk_alb.dns_name}"
}