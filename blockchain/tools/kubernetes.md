Install Minikube: https://kubernetes.io/docs/tasks/tools/install-minikube/
Learn more about Minikube: https://kubernetes.io/docs/setup/learning-environment/minikube/


### Convert docker-compose.yml to kubernetes
- Convert docker-compose.yml to kubernetes
```
kompose convert --volumes hostPath --verbose
```
- Start minikube:
```
sudo minikube start; sudo sudo chown -R $USER $HOME/.kube $HOME/.minikube
```
- Remove the extra hostpath that gets added like /home/kpachhai/home/kpachhai/blockchain/config.json. So, you would have to remove "/home/kpachhai" from each deployment.yaml file. Also make sure hostpath is correct
- Add the following in each deployment.yaml file right before template section:
  selector:
    matchLabels:
      io.kompose.service: privnet-api-misc-mainchain
- Add the following in each service.yaml file right after selector section:
  type: NodePort
- Dry run:
```
for i in $(ls | grep .yaml); do echo $i; sed -i 's#extensions/v1beta1#apps/v1#g' $i; kubectl apply --dry-run -f $i; done
```
- Fix any issues and run for real:
```
kubectl apply -R -f blockchain
```
- List the services:
```
minikube service list;
kubectl get svc
```
- Delete the pods:
```
kubectl -n blockchain delete pod,svc --all
minikube_stop
minikube delete
```

- Other info:
```
kubectl -n blockchain get deployment
kubectl -n default get pods
```