```bash
aws eks --region ap-northeast-2 update-kubeconfig --name spring-eks-dev
```


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

```bash
# 최초 슬롯 활성화(예: blue로 시작)
aws ssm put-parameter --name "/deploy/gateway/state/active_slot" --type String --value "blue" --overwrite --region ap-northeast-2
aws ssm put-parameter --name "/deploy/gateway/state/lock" --type String --value "false" --overwrite --region ap-northeast-2

# 슬롯 태그 초기화(처음엔 빈 값 가능)
aws ssm put-parameter --name "/deploy/gateway/slot/blue/tag"   --type String --value "" --overwrite --region ap-northeast-2
aws ssm put-parameter --name "/deploy/gateway/slot/blue/digest"--type String --value "" --overwrite --region ap-northeast-2
aws ssm put-parameter --name "/deploy/gateway/slot/green/tag"  --type String --value "" --overwrite --region ap-northeast-2
aws ssm put-parameter --name "/deploy/gateway/slot/green/digest"--type String --value "" --overwrite --region ap-northeast-2

# 가시성 키도 비워두고 시작 가능
aws ssm put-parameter --name "/deploy/gateway/current_tag"   --type String --value "" --overwrite --region ap-northeast-2
aws ssm put-parameter --name "/deploy/gateway/current_digest"--type String --value "" --overwrite --region ap-northeast-2

```
