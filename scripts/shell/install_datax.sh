#!/bin/bash

# DataX安装和服务配置脚本 - systemd统一版
# 适用于使用systemd的EulerOS(HCE)和Ubuntu 24.04系统

set -e

# 配置参数
DATAX_VERSION="202309"
DATAX_URL="https://datax-opensource.oss-cn-hangzhou.aliyuncs.com/${DATAX_VERSION}/datax.tar.gz"
DATAX_HOME="/opt/datax"
SERVICE_NAME="datax"

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用root用户运行此脚本"
    exit 1
fi

# 检查系统架构
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
    echo "警告：此脚本专为ARM(aarch64)架构设计，当前架构为$ARCH"
    read -p "是否继续？(y/n)" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查操作系统
if [ -f "/etc/hce-release" ]; then
    OS="HCE"
elif [ -f "/etc/os-release" ] && grep -q "Ubuntu 24.04" /etc/os-release; then
    OS="Ubuntu"
else
    echo "不支持的操作系统"
    exit 1
fi

# 安装依赖
echo "安装系统依赖..."
if [ "$OS" = "HCE" ]; then
    if ! command -v python3 &> /dev/null; then
        yum install -y python3 tar wget
    fi
elif [ "$OS" = "Ubuntu" ]; then
    if ! command -v python3 &> /dev/null; then
        apt-get update
        apt-get install -y python3 tar wget
    fi
fi

# 创建安装目录
mkdir -p "$DATAX_HOME"
cd "$DATAX_HOME"

# 下载并解压DataX
if [ ! -f "${DATAX_HOME}/bin/datax.py" ]; then
    echo "下载DataX..."
    wget "$DATAX_URL" -O datax.tar.gz
    tar -zxvf datax.tar.gz --strip-components=1
    rm -f datax.tar.gz
else
    echo "DataX已存在，跳过下载..."
fi

# 创建示例job.json
echo "创建示例job.json..."
if [ ! -f "${DATAX_HOME}/job/job.json" ]; then
    mkdir -p "${DATAX_HOME}/job"
    cat > "${DATAX_HOME}/job/job.json" << 'EOF'
{
    "job": {
        "content": [
            {
                "reader": {
                    "name": "streamreader",
                    "parameter": {
                        "sliceRecordCount": 10,
                        "column": [
                            {
                                "type": "long",
                                "value": "10"
                            },
                            {
                                "type": "string",
                                "value": "hello，你好，世界-DataX"
                            }
                        ]
                    }
                },
                "writer": {
                    "name": "streamwriter",
                    "parameter": {
                        "encoding": "UTF-8",
                        "print": true
                    }
                }
            }
        ],
        "setting": {
            "speed": {
                "channel": 2
            }
        }
    }
}
EOF
    echo "示例job.json已创建在 ${DATAX_HOME}/job/job.json"
fi

# 创建自检脚本
echo "创建自检脚本..."
cat > "${DATAX_HOME}/bin/self_test.sh" << EOF
#!/bin/bash
${DATAX_HOME}/bin/datax.py ${DATAX_HOME}/job/job.json
EOF
chmod +x "${DATAX_HOME}/bin/self_test.sh"

# 创建systemd服务
echo "配置systemd服务..."

# 主服务文件（状态服务）
cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=DataX Service
After=network.target
Documentation=man:datax(1)

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/echo "DataX已安装在 ${DATAX_HOME}"
ExecStop=/bin/echo "DataX没有运行中的服务需要停止"
ExecReload=/bin/echo "重新加载配置"

[Install]
WantedBy=multi-user.target
EOF

# 测试服务文件
cat > "/etc/systemd/system/${SERVICE_NAME}-test.service" << EOF
[Unit]
Description=DataX Test Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 ${DATAX_HOME}/bin/datax.py ${DATAX_HOME}/job/job.json
EOF

# 创建全局命令
cat > "/usr/local/bin/datax" << EOF
#!/bin/bash
python3 "${DATAX_HOME}/bin/datax.py" "\$@"
EOF
chmod +x "/usr/local/bin/datax"

# 重载systemd配置
systemctl daemon-reload
systemctl enable "${SERVICE_NAME}.service"

# 设置环境变量
echo "设置环境变量..."
if ! grep -q "DATAX_HOME" /etc/profile; then
    echo "export DATAX_HOME=${DATAX_HOME}" >> /etc/profile
    echo 'export PATH=$PATH:${DATAX_HOME}/bin' >> /etc/profile
fi

# 测试安装
echo "测试DataX安装..."
source /etc/profile
echo "运行自检作业..."
python3 "${DATAX_HOME}/bin/datax.py" "${DATAX_HOME}/job/job.json"

echo ""
echo "=============================================="
echo "DataX安装完成！"
echo "安装目录: ${DATAX_HOME}"
echo ""
echo "使用方法:"
echo "1. 直接运行: datax /path/to/your_job.json"
echo "2. 服务管理:"
echo "   - 检查状态: systemctl status datax"
echo "   - 运行测试: systemctl start datax-test"
echo ""
echo "已创建全局命令 'datax' 可直接使用"
echo "示例配置文件已创建在: ${DATAX_HOME}/job/job.json"
echo "=============================================="