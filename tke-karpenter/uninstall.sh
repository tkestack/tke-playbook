#!/bin/bash

# ==========================================================
# TKE Karpenter Uninstall Script
# 
# 本脚本可在本地运行，也可以作为在腾讯云控制台卸载资源的参考
# 如果您选择在腾讯云控制台卸载，请参考 README.md 中的说明
#
# This script can be run locally or used as a reference for 
# resource cleanup in Tencent Cloud Console. Please refer to README.md 
# for instructions on console resource management.
# ==========================================================

terraform destroy -auto-approve
