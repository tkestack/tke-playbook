# -*- coding: utf-8 -*-

import os
import sys
import json
import types
from tencentcloud.common import credential
from tencentcloud.common.profile.client_profile import ClientProfile
from tencentcloud.common.profile.http_profile import HttpProfile
from tencentcloud.common.exception.tencent_cloud_sdk_exception import TencentCloudSDKException
from tencentcloud.tke.v20180525 import tke_client, models

def main():
    # 从环境变量获取配置
    secret_id = os.getenv("TENCENTCLOUD_SECRET_ID")
    secret_key = os.getenv("TENCENTCLOUD_SECRET_KEY")
    cluster_id = os.getenv("TKE_CLUSTER_ID")
    region = os.getenv("TKE_REGION", "ap-singapore")  # 默认区域
    upgrade_type = os.getenv("TKE_UPGRADE_TYPE", "reset")  # 默认升级类型
    skip_pre_check = os.getenv("TKE_SKIP_PRE_CHECK", "False")  # 默认不跳过预检查
    
    # 检查必需参数
    if not secret_id or not secret_key:
        print("错误：缺少凭据信息")
        print("请设置环境变量 TENCENTCLOUD_SECRET_ID 和 TENCENTCLOUD_SECRET_KEY")
        sys.exit(1)
    
    if not cluster_id:
        print("错误：缺少集群ID")
        print("请设置环境变量 TKE_CLUSTER_ID")
        sys.exit(1)
    
    try:
        # 密钥信息从环境变量读取，需要提前在环境变量中设置 TENCENTCLOUD_SECRET_ID 和 TENCENTCLOUD_SECRET_KEY
        # 使用环境变量方式可以避免密钥硬编码在代码中，提高安全性
        # 生产环境建议使用更安全的密钥管理方案，如密钥管理系统(KMS)、容器密钥注入等
        # 请参见：https://cloud.tencent.com/document/product/1278/85305
        # 密钥可前往官网控制台 https://console.cloud.tencent.com/cam/capi 进行获取
        cred = credential.Credential(secret_id, secret_key)
        
        # 实例化一个http选项，可选的，没有特殊需求可以跳过
        httpProfile = HttpProfile()
        httpProfile.endpoint = f"tke.{region}.tencentcloudapi.com"

        # 实例化一个client选项，可选的，没有特殊需求可以跳过
        clientProfile = ClientProfile()
        clientProfile.httpProfile = httpProfile
        # 实例化要请求产品的client对象,clientProfile是可选的
        client = tke_client.TkeClient(cred, region, clientProfile)

        # 首先获取集群节点列表
        print("正在获取集群节点列表...")
        describe_req = models.DescribeClusterInstancesRequest()
        describe_params = {
            "ClusterId": cluster_id
        }
        describe_req.from_json_string(json.dumps(describe_params))
        
        describe_resp = client.DescribeClusterInstances(describe_req)
        
        # 提取节点实例ID列表
        instance_ids = []
        for instance in describe_resp.InstanceSet:
            # 只选择工作节点（排除master节点）
            if instance.InstanceRole == "WORKER":
                instance_ids.append(instance.InstanceId)
        
        if not instance_ids:
            print("错误：未找到可升级的工作节点")
            sys.exit(1)
        
        print(f"找到 {len(instance_ids)} 个工作节点: {instance_ids}")
        
        # 尝试升级节点
        print(f"正在尝试使用 {upgrade_type} 类型升级节点...")
        req = models.UpgradeClusterInstancesRequest()
        params = {
            "ClusterId": cluster_id,
            "Operation": "create",
            "UpgradeType": upgrade_type,
            "InstanceIds": instance_ids,
            "SkipPreCheck": skip_pre_check.lower() == "true"
        }
        req.from_json_string(json.dumps(params))

        # 返回的resp是一个UpgradeClusterInstancesResponse的实例，与请求对象对应
        resp = client.UpgradeClusterInstances(req)
        # 输出json格式的字符串回包
        print("集群节点升级请求已发送:")
        print(resp.to_json_string())

    except TencentCloudSDKException as err:
        print(f"[TencentCloudSDKException] code:{err.get_code()} message:{err.get_message()} requestId:{err.get_request_id()}")
        sys.exit(1)

if __name__ == "__main__":
    main()
