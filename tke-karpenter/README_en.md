# TKE Karpenter Auto Scaling Solution

[中文版本](./README.md)

## Overview

This solution integrates Karpenter to implement intelligent node auto-scaling for TKE clusters. Karpenter is an open-source Kubernetes node autoscaler that can quickly and efficiently launch and terminate nodes based on workload demands, optimizing resource utilization and reducing costs.

The solution offers the following advantages:

- **Fast Response**: Karpenter responds faster to workload changes compared to traditional horizontal node autoscalers
- **Cost Optimization**: Maximizes resource utilization by intelligently scheduling and timely releasing idle nodes
- **Flexibility**: Supports multiple instance types and availability zones, automatically selecting the most suitable node configuration
- **Simplified Management**: Reduces dependency on predefined node groups for more flexible node management

## File Description

- `cluster.tf` - TKE cluster and native node pool resource configuration
- `network.tf` - VPC, subnet, and security group resource configuration
- `provider.tf` - Terraform Provider configuration
- `variables.tf` - Variable definition file
- `nodeclass.yaml` - Karpenter node class configuration
- `nodepool.yaml` - Karpenter node pool configuration
- `deploy.sh` - One-click deployment script
- `uninstall.sh` - One-click uninstall script

## Usage

### Local Deployment (Recommended)

This solution is designed to be deployed by running the deployment script locally, creating the TKE cluster and Karpenter plugin. The detailed Karpenter configuration (nodeclass.yaml and nodepool.yaml) needs to be manually applied by users in the Tencent Cloud Console.

1. Install Terraform (recommended version 1.0+)
2. Install kubectl
3. Obtain Tencent Cloud access credentials (SecretId and SecretKey)
4. Ensure your account has sufficient quotas to create clusters and nodes

Execute the deployment script:
```bash
./deploy.sh
```

The script will perform the following operations:

1. **Initialize Working Directory**: Switch to the directory where the script is located
2. **Initialize Terraform**: Execute `terraform init` command
3. **Collect User Input**: Prompt the user to enter configuration information (SecretId, SecretKey, region, VPC CIDR, etc.)
4. **Apply Terraform Configuration**: Execute `terraform apply` command with user-provided parameters to create the cluster and related resources
5. **Wait for Cluster Creation**: Poll the cluster status, waiting up to 10 minutes
6. **Set kubeconfig**: Configure Kubernetes access credentials
7. **Wait for Nodes Ready**: Use `kubectl wait` command to ensure all nodes are ready
8. **Update Karpenter Configuration**: Replace the cluster ID in nodeclass.yaml and nodepool.yaml files

After the script execution is complete, you will have a fully configured TKE cluster integrated with the Karpenter auto-scaling plugin.

### Manually Apply Karpenter Configuration

After the deployment script is executed, you need to manually apply the Karpenter configuration in the Tencent Cloud Console:

1. Log in to the Tencent Cloud Console
2. Go to the TKE cluster management page
3. Select the newly created cluster
4. Find the Karpenter configuration option in the cluster management interface
5. Apply the following files in sequence:
   - `nodeclass.yaml` - Karpenter node class configuration
   - `nodepool.yaml` - Karpenter node pool configuration

The benefits of this design are:
- Simplifies the local deployment process, with the deployment script focusing only on cluster and plugin creation
- Users can flexibly adjust Karpenter configuration in the console according to actual needs
- Avoids the complexity of users needing to install and configure kubectl tools locally

### Configure Karpenter

After deployment, you need to apply Karpenter configuration:

1. Set kubeconfig:
   ```bash
   export KUBECONFIG=/path/to/kubeconfig.yaml
   ```

2. Apply Karpenter configuration:
   ```bash
   kubectl apply -f nodeclass.yaml
   kubectl apply -f nodepool.yaml
   ```

### View Output Information

After deployment, you can view the following information:
- `terraform output cluster_id` - Cluster ID
- `terraform output kubeconfig` - Cluster access credential file path

### Clean Up Resources

#### One-click Uninstall (Recommended)
```bash
./uninstall.sh
```

#### Manual Uninstall
```bash
terraform destroy
```

## Architecture Description

### Component Introduction

#### TKE Cluster
- Creates a managed TKE cluster
- Enables the Karpenter extension plugin
- Configures VPC-CNI network mode

#### Native Node Pool
- Creates an initial native node pool for running the Karpenter controller and other necessary system components
- Configures auto-scaling range (minimum 2 nodes, maximum 6 nodes)

#### Karpenter Configuration
- **NodeClass**: Defines infrastructure properties of nodes, such as subnets, security groups, SSH keys, etc.
- **NodePool**: Defines scheduling constraints and resource limits for nodes

### How It Works

1. When workloads require more resources, Karpenter selects appropriate node types based on constraints defined in NodePool
2. Karpenter interacts directly with cloud provider APIs to quickly launch new node instances
3. After new nodes join the cluster, Karpenter schedules pending Pods to the new nodes
4. When nodes remain under low utilization for extended periods, Karpenter gracefully terminates these nodes to save costs

## Configuration Description

### Main Variables

- `region`: The region where the cluster is located
- `vpc_cidr`: VPC CIDR block
- `cluster_version`: Kubernetes version
- `service_cidr`: Kubernetes Service CIDR
- `instance_type`: Node instance type
- `ssh_public_key`: SSH public key (optional)

### Karpenter Configuration

#### NodeClass Configuration
```yaml
apiVersion: karpenter.k8s.tke/v1beta1
kind: TKEMachineNodeClass
metadata:
  name: default
spec:
  # Internet accessibility configuration
  internetAccessible:
    chargeType: TrafficPostpaidByHour
    maxBandwidthOut: 2

  # System disk configuration
  systemDisk:
    size: 60
    type: CloudPremium

  # Data disk configuration
  dataDisks:
  - mountTarget: /var/lib/containerd
    size: 50
    type: CloudPremium
    fileSystem: ext4

  # Subnet selection
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: cls-${CLUSTER_ID}

  # Security group selection
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: cls-${CLUSTER_ID}

  # SSH key selection
  sshKeySelectorTerms:
    - tags:
        karpenter.sh/discovery: cls-${CLUSTER_ID}
```

#### NodePool Configuration
```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: test
spec:
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 5m
    budgets:
    - nodes: 10%
  template:
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.k8s.tke/instance-family
          operator: In
          values: ["S5","SA2"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: "karpenter.k8s.tke/instance-cpu"
          operator: Gt
          values: ["1"]
      nodeClassRef:
        group: karpenter.k8s.tke
        kind: TKEMachineNodeClass
        name: default
  limits:
    cpu: 10
```

## Trigger Conditions and Usage

### Node Auto Scaling-up Triggers

Karpenter will automatically create new nodes when:

1. **Insufficient Resources**: When Pods cannot be scheduled due to insufficient resources (CPU, memory, etc.)
2. **Node Selector Matching**: When Pod's nodeSelector or nodeAffinity does not match existing nodes
3. **Taint Tolerance**: When Pod's tolerations cannot match the taints of existing nodes
4. **Topology Distribution Constraints**: When Pod's topologySpreadConstraints cannot be satisfied

### Node Auto Scaling-down Triggers

Karpenter will automatically terminate nodes when:

1. **Node Idle**: Node has no running Pods (except system Pods) for 5 consecutive minutes
2. **Low Node Utilization**: Node resource utilization is consistently low and can be optimized by rescheduling Pods to other nodes
3. **TTL Expiration**: Node reaches maximum lifetime (if ttlSecondsUntilExpired is configured)

### Usage Examples

#### 1. Deploy Application and Observe Auto Scaling-up

Create an application with high resource requirements:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: app
        image: nginx
        resources:
          requests:
            cpu: "1"
            memory: "1Gi"
```

Apply the configuration:
```bash
kubectl apply -f sample-app.yaml
```

Observe node auto scaling-up:
```bash
kubectl get nodes -w
```

#### 2. Observe Auto Scaling-down

Reduce application replicas:
```bash
kubectl scale deployment sample-app --replicas=0
```

Observe node auto scaling-down (after about 5 minutes):
```bash
kubectl get nodes -w
```

#### 3. View Karpenter Logs

Monitor Karpenter decision-making process:
```bash
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter -f
```

## Notes

- Cluster creation may take 10-15 minutes
- Ensure your account has sufficient quotas to create clusters and nodes
- It is recommended to verify in a test environment before using in production
- SSH key is optional, but if provided, it will help with node troubleshooting
- Karpenter's auto-scaling feature will only be triggered after applying workloads
