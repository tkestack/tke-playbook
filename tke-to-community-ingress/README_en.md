# TKE NginxIngress Component Migration to Self-hosted Ingress-nginx Guide

[中文版本](./README.md)

## Background
The TKE NginxIngress extension component is no longer supported in TKE version 1.30 and above. To upgrade the cluster version to 1.30 or higher, the TKE NginxIngress extension component in the lower version cluster needs to be removed and switched to the community version Ingress-nginx.

To achieve lossless traffic switching, this document provides two different migration solutions to help users choose the most suitable approach based on their needs, smoothly complete the TKE NginxIngress switch upgrade, and ensure smooth business traffic transition.

## Migration Solution Comparison

### Solution 1: Independent IngressClass Approach (Recommended)
- **Directory**: [tke-migrate-to-community-ingress](./tke-migrate-to-community-ingress/)
- **Core Idea**: Create a completely new IngressClass, fully independent from the original TKE IngressClass
- **Features**:
  - Complete isolation between new and old controllers, no mutual interference
  - Traffic switching through DNS switching
  - Safest migration process with simple rollback
  - Suitable for production environments with extremely high stability requirements

### Solution 2: Shared IngressClass Approach
- **Directory**: [tke-install-community-ingress](./tke-install-community-ingress/)
- **Core Idea**: Reuse the original IngressClass, with new and old controllers sharing the same IngressClass
- **Features**:
  - No need to modify existing Ingress resources
  - Traffic switching through weight adjustment
  - Relatively complex configuration requiring precise control
  - Suitable for scenarios where minimal configuration changes are desired

## Detailed Solution Descriptions

### Solution 1: Independent IngressClass Approach

In this solution, we deploy two completely independent Ingress controllers:
- Retain the original TKE NginxIngress controller (using IngressClass `test`)
- Deploy the new community Ingress-nginx controller (using IngressClass `new-test`)

The two controllers operate independently, with traffic switched from the old controller to the new controller through DNS modification.

**Advantages**:
- Good isolation, new and old environments do not interfere with each other
- Lowest risk during migration process
- Simple and direct rollback operations
- Easy to monitor and debug

**Applicable Scenarios**:
- Production environment migration
- Scenarios with extremely high business continuity requirements
- Users conducting this type of migration for the first time

### Solution 2: Shared IngressClass Approach

In this solution, we have the new community Ingress-nginx controller reuse the original IngressClass:
- Retain the original TKE NginxIngress controller (using IngressClass `test`)
- Deploy the new community Ingress-nginx controller (also using IngressClass `test`)
- Control traffic distribution through weight configuration

The two controllers share the same IngressClass, with traffic switching achieved through weight adjustment.

**Advantages**:
- No need to modify existing Ingress resources
- Minimal configuration changes
- Can achieve progressive migration

**Applicable Scenarios**:
- Scenarios where minimal configuration changes are desired
- Environments requiring progressive migration
- Situations with a large number of Ingress resources that are inconvenient to modify individually

## Usage Guide

### Choosing the Right Solution
1. **Solution 1**: If you pursue the highest security and simplest rollback operations, Solution 1 is recommended
2. **Solution 2**: If you want to minimize configuration changes and can accept slightly more complex configuration, Solution 2 can be chosen

### Implementation Steps
Regardless of which solution is chosen, the basic implementation steps are similar:

1. **Environment Preparation**: Deploy a simulated TKE NginxIngress component environment
2. **New Controller Deployment**: Deploy the new Ingress-nginx controller according to the chosen solution
3. **Smooth Migration**: Achieve traffic migration through DNS switching or weight adjustment
4. **Verification and Confirmation**: Verify the stability and availability of services after migration

### Notes
- Both solutions require Kubernetes version >= 1.14 and <= 1.28
- It is recommended to closely monitor business metrics during the migration process
- It is recommended to perform migration operations during business low periods
- Prepare a rollback plan to deal with unexpected situations

## Directory Structure
```
tke-to-community-ingress/
├── tke-migrate-to-community-ingress/           # Solution 1: Independent IngressClass Approach
│   ├── README.md         # Detailed instructions for Solution 1
│   ├── values.yaml       # Helm configuration file
│   ├── install-tke-ingress.sh     # Script to deploy TKE Ingress
│   ├── install-community-ingress.sh  # Script to deploy community Ingress
│   └── migrate.sh        # Migration script
└── tke-install-community-ingress/           # Solution 2: Shared IngressClass Approach
    ├── README.md         # Detailed instructions for Solution 2
    ├── values.yaml       # Helm configuration file
    ├── install-tke-ingress.sh     # Script to deploy TKE Ingress
    ├── install-community-ingress.sh  # Script to deploy community Ingress
    └── migrate.sh        # Migration script
```

Choose the solution that fits your needs and enter the corresponding directory to view detailed implementation steps and configuration instructions.
