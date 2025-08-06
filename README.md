***AWS CLI Infra controller***

plugin install aws
![img_1.png](static/img_1.png)

입력후 발급받은 accesskey, secretkey 입력
``` bash
aws configure
```
![img.png](static/img.png)
   
```bash
 aws eks list-clusters --region ap-northeast-2
```
terraform plan
![img_2.png](static/img_2.png)

terraform apply -auto-approve
![img_4.png](static/img_4.png)

aws 확인
![img_3.png](static/img_3.png)
보안그룹 생성확인
![img_5.png](static/img_5.png)
