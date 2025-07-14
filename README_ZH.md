<p align="center">
  <h1 align="center">Datax 数据同步</h1>
  <p align="center">
    <a href="README.md"><strong>English</strong></a> | <strong>简体中文</strong>
  </p>
</p>

## 目录

- [仓库简介](#项目介绍)
- [前置条件](#前置条件)
- [镜像说明](#镜像说明)
- [获取帮助](#获取帮助)
- [如何贡献](#如何贡献)

## 项目介绍
‌[Datax‌](https://github.com/alibaba/DataX) DataX 是阿里巴巴开源的一个异构数据源离线同步工具。

**核心特性：**
1. 异构数据源支持：DataX支持多种异构数据源之间的高效数据同步，包括关系型数据库（MySQL、Oracle、SQL Server等）、NoSQL（MongoDB、HBase）、大数据存储（HDFS、Hive）、消息队列（Kafka）、文件系统（FTP、OSS/S3）等，覆盖企业级数据集成场景。
2. 分布式架构与高扩展性：采用框架+插件式设计，核心调度与数据读写分离，可通过扩展插件支持新数据源。支持多线程并发读写，线性提升数据传输效率，适应TB级数据迁移需求。
3. 断点续传与容错机制：任务执行过程中自动记录检查点（Checkpoint），异常中断后可从断点恢复，避免重复传输。提供脏数据检测与跳过/记录策略，保障任务可靠性。
4. 精准的数据一致性保障：基于批次控制（Batch）和事务机制，确保数据同步的原子性和一致性。支持全量同步、增量同步（如基于时间戳或Binlog）、以及动态SQL过滤，满足不同业务场景需求。
5. 低资源消耗与高性能：通过内存优化、流式传输、数据分片等技术，单机可达数千条/秒的传输速率（视数据源性能而定）。支持网络压缩传输，减少带宽占用。
6. 灵活的任务配置与监控：提供JSON/脚本化配置方式，支持动态参数注入。内置任务进度监控、速率统计、脏数据比例等指标，可集成Prometheus等监控系统。
7. 企业级安全支持：支持数据传输加密（SSL/TLS）、敏感信息脱敏、数据源权限控制（如Kerberos认证），满足金融、政务等场景的安全合规要求。
8. 生态兼容性：无缝对接阿里云DataWorks等调度平台，支持与MaxCompute、Flink等大数据组件联动。开源社区提供丰富的插件扩展，用户可自定义Reader/Writer插件。

本项目提供的开源镜像商品 [**`Datax-数据同步`**]()，已预先安装 Datax 软件及其相关运行环境，并提供部署模板。快来参照使用指南，轻松开启“开箱即用”的高效体验吧。

**架构设计：**

![](./images/img.png)

> **系统要求如下：**
> - CPU: 4vCPUs 或更高
> - RAM: 16GB 或更大
> - Disk: 至少 50GB

## 前置条件
[注册华为账号并开通华为云](https://support.huaweicloud.com/usermanual-account/account_id_001.html)

## 镜像说明

| 镜像规格                                                                                                                          | 特性说明 | 备注 |
|-------------------------------------------------------------------------------------------------------------------------------| --- | --- |
| [Datax202309-kunpeng-v1.0](https://github.com/HuaweiCloudDeveloper/datax-image/tree/Datax202309-arm-v1.0?tab=readme-ov-file) | 基于鲲鹏服务器 + Huawei Cloud EulerOS 2.0 64bit 安装部署 |  |

## 获取帮助
- 更多问题可通过 [issue](https://github.com/HuaweiCloudDeveloper/datax-image/issues) 或 华为云云商店指定商品的服务支持 与我们取得联系
- 其他开源镜像可看 [open-source-image-repos](https://github.com/HuaweiCloudDeveloper/open-source-image-repos)

## 如何贡献
- Fork 此存储库并提交合并请求
- 基于您的开源镜像信息同步更新 README.md