
vpc 확인
```bash 
aws ec2 describe-vpcs --region ap-northeast-2
```

vpc 아이디만보기
```bash
aws ec2 describe-vpcs \
  --query 'Vpcs[*].VpcId' \
  --output text \
  --region ap-northeast-2
```

subnet list
```bash
aws ec2 describe-subnets --region ap-northeast-2
```

subnet 가용영역
```bash
aws ec2 describe-subnets \
  --query 'Subnets[*].[SubnetId, AvailabilityZone, CidrBlock]' \
  --output table \
  --region ap-northeast-2
```

route table
```bash
aws ec2 describe-route-tables --region ap-northeast-2
```

Internet Gateway
```bash
aws ec2 describe-internet-gateways --region ap-northeast-2
```
nat gateway
```bash
aws ec2 describe-nat-gateways --region ap-northeast-2
```
route53
```bash
aws route53 list-hosted-zones
```
ecr
```bash
aws ecr describe-repositories --region ap-northeast-2
```

alb/elb
```bash
aws elbv2 describe-load-balancers --region ap-northeast-2
```
