
rem https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html

rem variable set ---------------------------------
set region=ap-northeast-2
set eks=EKS-cluster01
set id=524297582387

rem eks register---------------------------------
aws eks --region %region% update-kubeconfig --name %eks%

rem create file directory----------------------------
mkdir C:\Users\user\kubernetes-project
cd C:\Users\user\kubernetes-project

rem oidc provider create ---------------------------------
eksctl utils associate-iam-oidc-provider --region %region% --cluster %eks% --approve

rem policy curl---------------------------------
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.1/docs/install/iam_policy.json

rem create ALB policy---------------------------------
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam-policy.json

rem create ALB-SA---------------------------------
eksctl create iamserviceaccount --cluster=EKS-cluster01 --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::%id%0:policy/AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --approve

rem install alb via helm--------------------------------- 
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=%eks% --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

rem Check-----------------------------------------
kubectl get deployment -n kube-system aws-load-balancer-controller

rem efs policy create------------------------------
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/docs/iam-policy-example.json
aws iam create-policy --policy-name AmazonEKS_EFS_CSI_Driver_Policy --policy-document file://iam-policy-example.json

rem create efs-sa---------------------------
eksctl create iamserviceaccount --cluster %eks% --namespace kube-system --name efs-csi-controller-sa --attach-policy-arn arn:aws:iam::%id%:policy/AmazonEKS_EFS_CSI_Driver_Policy --approve --region %region%

rem install efs-driver via helm---------------------------------
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo update
helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver --namespace kube-system --set image.repository=602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/eks/aws-efs-csi-driver --set controller.serviceAccount.create=false --set controller.serviceAccount.name=efs-csi-controller-sa












