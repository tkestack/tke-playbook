# TKE API 参数详解

本文档详细介绍了TKE集群控制平面升级和节点升级接口的所有可用参数，帮助用户了解如何根据需要扩展脚本功能。

## 集群控制平面升级参数 (UpdateClusterVersion)

### 必选参数

| 参数名称 | 类型 | 描述 |
|---------|------|------|
| Action | String | 接口名称，取值：UpdateClusterVersion |
| Version | String | API版本，取值：2018-05-25 |
| Region | String | 地域标识，详见[地域列表](https://cloud.tencent.com/document/api/457/31856#.E5.9C.B0.E5.9F.9F.E5.88.97.E8.A1.A8) |
| ClusterId | String | 集群ID |
| DstVersion | String | 目标版本 |

### 可选参数

| 参数名称 | 类型 | 描述 |
|---------|------|------|
| ExtraArgs | [ClusterExtraArgs](https://cloud.tencent.com/document/api/457/31866#ClusterExtraArgs) | 集群自定义参数 |
| MaxNotReadyPercent | Float | 可容忍的最大不可用Pod比例 |
| SkipPreCheck | Boolean | 是否跳过预检查阶段 |

## 集群节点升级参数 (UpgradeClusterInstances)

### 必选参数

| 参数名称 | 类型 | 描述 |
|---------|------|------|
| Action | String | 接口名称，取值：UpgradeClusterInstances |
| Version | String | API版本，取值：2018-05-25 |
| Region | String | 地域标识，详见[地域列表](https://cloud.tencent.com/document/api/457/31856#.E5.9C.B0.E5.9F.9F.E5.88.97.E8.A1.A8) |
| ClusterId | String | 集群ID |
| Operation | String | 操作类型，可选值：create/pause/resume/abort |

### 可选参数

| 参数名称 | 类型 | 描述 |
|---------|------|------|
| UpgradeType | String | 升级类型，仅当Operation为create时有效，可选值：reset/hot/major |
| InstanceIds.N | Array of String | 需要升级的节点列表 |
| ResetParam | [UpgradeNodeResetParam](https://cloud.tencent.com/document/api/457/31866#UpgradeNodeResetParam) | 节点重新加入集群时使用的参数 |
| SkipPreCheck | Boolean | 是否忽略节点升级前检查 |
| MaxNotReadyPercent | Float | 最大可容忍的不可用Pod比例 |
| UpgradeRunTime | Boolean | 是否升级节点运行时 |

## 如何在脚本中添加新参数

如果您需要在脚本中使用上述未实现的参数，可以按照以下步骤进行扩展：

### 1. 在环境变量中添加参数

在 `run_updatecluster.sh` 或 `upgrade_nodes.sh` 脚本中添加新的环境变量：

```bash
# 添加额外参数示例
export TKE_MAX_NOT_READY_PERCENT="100"
export TKE_EXTRA_ARGS='{"KubeletArgs": {"max-pods": "100"}}'
```

### 2. 在Python脚本中读取参数

在 `updatecluster.py` 或 `upgradeClusterInstance.py` 中读取环境变量：

```python
# 读取额外参数
max_not_ready_percent = os.getenv("TKE_MAX_NOT_READY_PERCENT")
extra_args = os.getenv("TKE_EXTRA_ARGS")
```

### 3. 在API请求中使用参数

将参数添加到API请求中：

```python
# 对于集群控制平面升级
params = {
    "ClusterId": cluster_id,
    "DstVersion": dst_version,
    "SkipPreCheck": skip_pre_check.lower() == "true"
}

# 如果设置了额外参数，则添加到请求中
if max_not_ready_percent:
    params["MaxNotReadyPercent"] = float(max_not_ready_percent)

if extra_args:
    params["ExtraArgs"] = json.loads(extra_args)

req.from_json_string(json.dumps(params))
```

```python
# 对于节点升级
params = {
    "ClusterId": cluster_id,
    "Operation": "create",
    "UpgradeType": upgrade_type,
    "InstanceIds": instance_ids,
    "SkipPreCheck": skip_pre_check.lower() == "true"
}

# 如果设置了额外参数，则添加到请求中
if max_not_ready_percent:
    params["MaxNotReadyPercent"] = float(max_not_ready_percent)

if upgrade_run_time:
    params["UpgradeRunTime"] = upgrade_run_time.lower() == "true"

req.from_json_string(json.dumps(params))
```

## 注意事项

1. 在添加新参数时，请确保遵循腾讯云API文档中的参数类型和取值要求
2. 对于布尔类型参数，建议使用字符串"true"/"false"并在代码中转换
3. 对于JSON类型参数，需要使用`json.loads()`进行解析
4. 在生产环境中使用前，请先在测试环境中验证参数效果
5. 建议保留现有参数的兼容性，新增参数采用可选方式实现

## 参考文档

- [UpdateClusterVersion](https://cloud.tencent.com/document/api/457/32022)
- [UpgradeClusterInstances](https://cloud.tencent.com/document/api/457/32021)
- [地域列表](https://cloud.tencent.com/document/api/457/31856#.E5.9C.B0.E5.9F.9F.E5.88.97.E8.A1.A8)
