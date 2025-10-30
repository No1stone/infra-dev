환경 초기화
```bash
terraform init
```
실행 전 검토
```bash
terraform plan
```
리소스 생성 병경 적용
```bash
terraform apply -auto-approve
```
리소스 전체 삭제
```bash
terraform destroy -auto-approve
```
리소스 목록출력
```bash
terraform state list
```
현재상태 출력
```bash
terraform show 
```
특정리소스보기
```bash
terraform status show {resource}
```
상태 백업 복원
```bash
terraform status pull > backup.tfstate
terraform state push backup.tfstate
```
상태제거
```bash
terraform state rm {resource}
```
```bash
terraform import {resource} {resourceId}
```

```bash
terraform apply -target=aws_instance.resource_server -auto-approve
```

```bash
terraform destroy -target=aws_instance.resource_server -auto-approve
```
```text
sudo tail -n 200 /var/log/cloud-init-output.log
```