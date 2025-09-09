# TKE NginxIngress Component Migration to Self-Hosted Ingress-nginx Guide

## Background
The TKE NginxIngress extension component is no longer supported in TKE version 1.30 and above. To upgrade the cluster version to 1.30 or higher, the TKE NginxIngress extension component in the older cluster must be removed and switched to the community version of Ingress-nginx.

To achieve lossless switching of live traffic, this document provides two different migration solutions to help users select the most suitable approach based on their needs, ensuring a smooth transition of TKE NginxIngress upgrades and stable business traffic transition.

## Migration Solution Comparison

### Solution 1: Independent IngressClass Approach (Recommended)
- **Directory**: [solution-1](solution-1/)
- **Core Concept**: Create a completely new IngressClass independent from the original TKE IngressClass
- **Features**:
  - Complete isolation between new and old controllers without mutual interference
  - Traffic switching through DNS changes
  - Safest migration process with simple rollback
  - Suitable for production environments with extremely high stability requirements

### Solution 2: Shared IngressClass Approach
- **Directory**: [solution-2](solution-2/)
- **Core Concept**: Reuse the original IngressClass with both new and old controllers sharing the same IngressClass
- **Features**:
  - No modification required to existing Ingress resources
  - Traffic switching through weight adjustment
  - Relatively complex configuration requiring precise control
  - Suitable for scenarios where minimal configuration changes are desired

## Detailed Solution Descriptions

### Solution 1: Independent IngressClass Approach

In this solution, we deploy two completely independent Ingress controllers:
- Retain the original TKE NginxIngress controller (using IngressClass `test`)
- Deploy a new community Ingress-nginx controller (using IngressClass `new-test`)

Both controllers operate independently, with traffic switched from the old controller to the new controller by modifying DNS resolution.

**Advantages**:
- Good isolation with no interference between old and new environments
- Lowest risk during migration process
- Simple and direct rollback operations
- Easy monitoring and debugging

**Applicable Scenarios**:
- Production environment migration
- Scenarios with extremely high business continuity requirements
- Users conducting this type of migration for the first time

### Solution 2: Shared IngressClass Approach

In this solution, the new community Ingress-nginx controller reuses the original IngressClass:
- Retain the original TKE NginxIngress controller (using IngressClass `test`)
- Deploy a new community Ingress-nginx controller (also using IngressClass `test`)
- Control traffic distribution through weight configuration

Both controllers share the same IngressClass, with traffic switching achieved by adjusting weights.

**Advantages**:
- No modification required to existing Ingress resources
- Minimal configuration changes
- Enables progressive migration

**Applicable Scenarios**:
- Scenarios where minimal configuration changes are desired
- Environments requiring progressive migration
- Situations with numerous Ingress resources that are inconvenient to modify individually

## Usage Guide

### Selecting the Right Solution
1. **Solution 1**: Recommended if you pursue maximum security and simplest rollback operations
2. **Solution 2**: Choose if you want to minimize configuration changes and can accept slightly more complex configurations

### Implementation Steps
Regardless of which solution is chosen, the basic implementation steps are similar:

1. **Environment Preparation**: Deploy a simulated TKE NginxIngress component environment
2. **New Controller Deployment**: Deploy the new Ingress-nginx controller according to the selected solution
3. **Smooth Migration**: Achieve traffic migration through DNS switching or weight adjustment
4. **Verification and Confirmation**: Verify the stability and availability of services after migration

### Precautions
- Both solutions require Kubernetes version >= 1.14 and <= 1.28
- Close monitoring of business metrics is recommended during the migration process
- It is recommended to perform migration operations during business low periods
- Prepare rollback plans to handle unexpected situations

## Directory Structure
```
tke-to-community-ingress/
├── solution-1/           # Solution 1: Independent IngressClass Approach
│   ├── README.md         # Detailed instructions for Solution 1
│   ├── values.yaml       # Helm configuration file
│   ├── install-tke-ingress.sh     # Script to deploy TKE Ingress
│   ├── install-community-ingress.sh  # Script to deploy community Ingress
│   └── migrate.sh        # Migration script
└── solution-2/           # Solution 2: Shared IngressClass Approach
    ├── README.md         # Detailed instructions for Solution 2
    ├── values.yaml       # Helm configuration file
    ├── install-tke-ingress.sh     # Script to deploy TKE Ingress
    ├── install-community-ingress.sh  # Script to deploy community Ingress
    └── migrate.sh        # Migration script
```

Select the solution that best fits your needs and enter the corresponding directory to view detailed implementation steps and configuration instructions.
