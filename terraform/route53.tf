data "aws_route53_zone" "root" {
  name         = "origemite.com."
  private_zone = false
}

resource "aws_route53_record" "gateway_a" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "gateway.origemite.com"
  type    = "A"
  ttl     = 60
  records = ["43.202.195.185"]
}
