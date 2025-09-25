# TKE API Parameters Detailed Explanation

This document provides detailed information about all available parameters for TKE cluster control plane upgrade and node upgrade interfaces, helping users understand how to extend script functionality as needed.

## Cluster Control Plane Upgrade Parameters (UpdateClusterVersion)

### Required Parameters

| Parameter Name | Type | Description |
|---------------|------|-------------|
| Action | String | Interface name, value: UpdateClusterVersion |
| Version | String | API version, value: 2018-05-25 |
| Region | String | Region identifier, see [Region List](https://cloud.tencent.com/document/api/457/31856#.E5.9C.B0.E5.9F.9F.E5.88.97.E8.A1.A8) |
| ClusterId | String | Cluster ID |
| DstVersion | String | Target version |

### Optional Parameters

| Parameter Name | Type | Description |
|---------------|------|-------------|
| ExtraArgs | [ClusterExtraArgs](https://cloud.tencent.com/document/api/457/31866#ClusterExtraArgs) | Cluster custom parameters |
| MaxNotReadyPercent | Float | Maximum tolerable unavailable Pod ratio |
| SkipPreCheck | Boolean | Whether to skip pre-check phase |

## Cluster Node Upgrade Parameters (UpgradeClusterInstances)

### Required Parameters

| Parameter Name | Type | Description |
|---------------|------|-------------|
| Action | String | Interface name, value: UpgradeClusterInstances |
| Version | String | API version, value: 2018-05-25 |
| Region | String | Region identifier, see [Region List](https://cloud.tencent.com/document/api/457/31856#.E5.9C.B0.E5.9F.9F.E5.88.97.E8.A1.A8) |
| ClusterId | String | Cluster ID |
| Operation | String | Operation type, options: create/pause/resume/abort |

### Optional Parameters

| Parameter Name | Type | Description |
|---------------|------|-------------|
| UpgradeType | String | Upgrade type, only valid when Operation is create, options: reset/hot/major |
| InstanceIds.N | Array of String | List of nodes to upgrade |
| ResetParam | [UpgradeNodeResetParam](https://cloud.tencent.com/document/api/457/31866#UpgradeNodeResetParam) | Parameters used when node rejoins the cluster |
| SkipPreCheck | Boolean | Whether to ignore node upgrade pre-check |
| MaxNotReadyPercent | Float | Maximum tolerable unavailable Pod ratio |
| UpgradeRunTime | Boolean | Whether to upgrade node runtime |

## How to Add New Parameters to Scripts

If you need to use the above unimplemented parameters in your scripts, you can extend them following these steps:

### 1. Add Parameters in Environment Variables

Add new environment variables in `run_updatecluster.sh` or `upgrade_nodes.sh` scripts:

```bash
# Example of adding extra parameters
export TKE_MAX_NOT_READY_PERCENT="100"
export TKE_EXTRA_ARGS='{"KubeletArgs": {"max-pods": "100"}}'
```

### 2. Read Parameters in Python Scripts

Read environment variables in `updatecluster.py` or `upgradeClusterInstance.py`:

```python
# Read extra parameters
max_not_ready_percent = os.getenv("TKE_MAX_NOT_READY_PERCENT")
extra_args = os.getenv("TKE_EXTRA_ARGS")
```

### 3. Use Parameters in API Requests

Add parameters to API requests:

```python
# For cluster control plane upgrade
params = {
    "ClusterId": cluster_id,
    "DstVersion": dst_version,
    "SkipPreCheck": skip_pre_check.lower() == "true"
}

# If extra parameters are set, add them to the request
if max_not_ready_percent:
    params["MaxNotReadyPercent"] = float(max_not_ready_percent)

if extra_args:
    params["ExtraArgs"] = json.loads(extra_args)

req.from_json_string(json.dumps(params))
```

```python
# For node upgrade
params = {
    "ClusterId": cluster_id,
    "Operation": "create",
    "UpgradeType": upgrade_type,
    "InstanceIds": instance_ids,
    "SkipPreCheck": skip_pre_check.lower() == "true"
}

# If extra parameters are set, add them to the request
if max_not_ready_percent:
    params["MaxNotReadyPercent"] = float(max_not_ready_percent)

if upgrade_run_time:
    params["UpgradeRunTime"] = upgrade_run_time.lower() == "true"

req.from_json_string(json.dumps(params))
```

## Notes

1. When adding new parameters, ensure compliance with parameter types and value requirements in Tencent Cloud API documentation
2. For Boolean type parameters, it is recommended to use strings "true"/"false" and convert them in code
3. For JSON type parameters, use `json.loads()` for parsing
4. Validate parameter effects in test environments before using in production
5. Maintain compatibility with existing parameters, implement new parameters as optional

## Reference Documentation

- [UpdateClusterVersion](https://cloud.tencent.com/document/api/457/32022)
- [UpgradeClusterInstances](https://cloud.tencent.com/document/api/457/32021)
- [Region List](https://cloud.tencent.com/document/api/457/31856#.E5.9C.B0.E5.9F.9F.E5.88.97.E8.A1.A8)
