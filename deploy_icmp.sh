#!/bin/bash

set -e

echo "创建日志目录 /ping_logs 并设置权限..."
mkdir -p /ping_logs
chmod 777 /ping_logs

echo "创建执行脚本 /d-icmp ..."
cat > /d-icmp << 'EOF'
#!/bin/bash

LOG_DIR="/ping_logs"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/ping_$(date +%F).log"

nohup ping 8.8.8.8 > "$LOG_FILE" 2>&1 &
EOF

chmod +x /d-icmp

echo "创建启动脚本 /icmp-a ..."
cat > /icmp-a << 'EOF'
#!/bin/bash

nohup /d-icmp &
EOF

chmod +x /icmp-a

echo "设置 root crontab 自动清理两天前日志..."
(crontab -l 2>/dev/null | grep -v 'find /ping_logs -type f -mtime +2 -delete'; echo "0 0 * * * find /ping_logs -type f -mtime +2 -delete") | crontab -

echo "启动 /icmp-a 脚本（后台）..."
nohup /icmp-a &

echo "部署完成！"
echo "用命令 'pgrep -af ping' 查看 ping 进程"
echo "日志文件目录：/ping_logs ，实时查看：tail -f /ping_logs/ping_$(date +%F).log"