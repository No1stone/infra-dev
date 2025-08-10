```bash
kubectl config get-contexts
```
```bash
kubectl config use-context arn:aws:eks:ap-northeast-2:<계정번호>:cluster/spring-eks-dev
```



```bash
kubectl get pods
```

```bash
kubectl get svc
```

```bash
kubectl get deployments
```

```bash
kubectl get all
```

```bash
kubectl get ns
```

```bash
kubectl get events
```

```bash
kubectl describe pod <파드명>
```

```bash
kubectl describe svc <서비스명>
```

```bash
kubectl logs <파드명>
```

```bash
kubectl logs -f <파드명>
```

```bash
kubectl apply -f <파일명>.yaml
```


```bash
kubectl delete -f <파일명>.yaml
```


```bash
kubectl delete pod <파드명>
```


```bash
kubectl exec -it <파드명> -- /bin/sh
```


```bash
kubectl port-forward svc/<서비스명> <로컬포트>:<서비스포트>
```


```bash
kubectl rollout restart deployment <디플로이먼트명>
```


```bash
kubectl edit deployment <디플로이먼트명>
```