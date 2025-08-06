# KB Upload Genie - 容器化部署指南

## 项目概述

KB Upload Genie 是一个前后端分离的GitHub上传分类智能系统，支持邮件附件上传、文件管理、用户认证等功能。本项目采用Docker容器化部署方案，确保在云服务器环境中稳定运行。

## 技术架构

- **后端**: FastAPI + Python 3.11 + uvicorn
- **前端**: React + TypeScript + Vite + Nginx
- **数据库**: PostgreSQL 15
- **缓存**: Redis 7
- **容器化**: Docker + Docker Compose
- **架构**: 统一容器部署（前端+后端+Nginx）

## 部署方案

### 方案一：本地构建部署

适用于开发环境或小规模部署：

```bash
# 克隆项目
git clone <your-repository-url>
cd kb_upload_genie

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件，修改数据库密码、Redis密码等配置

# 一键部署
./deploy.sh start
```

### 方案二：云端构建部署

适用于生产环境，推荐使用：

#### 1. 构建和推送镜像

```bash
# 在开发机器上构建并推送镜像
./build-and-push.sh registry.cn-hangzhou.aliyuncs.com/your-namespace latest

# 或者使用自定义参数
./build-and-push.sh your-registry.com/your-namespace v1.0.0
```

#### 2. 在服务器上部署

```bash
# 在服务器上配置环境变量
cp .env.example .env
# 编辑 .env 文件，设置 APP_IMAGE 为你的镜像地址
# APP_IMAGE=registry.cn-hangzhou.aliyuncs.com/your-namespace/kb-upload-genie:latest

# 启动服务
./deploy.sh start
```

## 环境配置

### 必需配置项

```bash
# 数据库配置
POSTGRES_DB=kb_upload_genie
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password_here

# Redis配置
REDIS_PASSWORD=your_redis_password_here

# 应用配置
SECRET_KEY=your_very_long_and_secure_secret_key_here
ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com

# 镜像配置（云端部署时使用）
APP_IMAGE=registry.cn-hangzhou.aliyuncs.com/your-namespace/kb-upload-genie:latest
```

### 可选配置项

```bash
# 邮件上传功能
EMAIL_UPLOAD_ENABLED=true
IMAP_SERVER=imap.gmail.com
EMAIL_ADDRESS=your-email@gmail.com
EMAIL_PASSWORD=your-app-password

# AI功能
OPENAI_API_KEY=your-openai-api-key
```

## 服务访问

部署成功后，可通过以下地址访问：

- **前端管理界面**: http://your-server-ip
- **后端API文档**: http://your-server-ip/docs
- **健康检查**: http://your-server-ip/health

## 部署脚本命令

```bash
# 启动所有服务
./deploy.sh start

# 停止所有服务
./deploy.sh stop

# 重启所有服务
./deploy.sh restart

# 查看服务状态
./deploy.sh status

# 查看服务日志
./deploy.sh logs

# 检查服务健康状态
./deploy.sh health

# 备份数据
./deploy.sh backup

# 清理Docker资源
./deploy.sh cleanup
```

## 架构特点

### 统一容器设计

- **单一容器**: 前端静态文件和后端API服务打包在同一容器中
- **Nginx反向代理**: 容器内使用Nginx处理静态文件服务和API代理
- **Supervisor进程管理**: 使用supervisor管理Nginx和FastAPI两个进程
- **单端口暴露**: 只对外暴露80端口，简化网络配置

### 多阶段构建优化

- **前端构建阶段**: 使用Node.js 18构建React应用
- **运行时阶段**: 使用Python 3.11-slim作为运行时基础镜像
- **镜像优化**: 通过.dockerignore和多阶段构建减少镜像体积

### 生产环境特性

- **健康检查**: 内置应用健康检查机制
- **日志管理**: 统一的日志收集和管理
- **安全配置**: 非root用户运行，安全头配置
- **数据持久化**: 使用Docker volumes持久化数据

## 故障排除

### 常见问题

1. **构建失败 - ARM64架构问题**
   ```bash
   # 如果在ARM64 Mac上构建失败，确保使用正确的Node.js版本
   # Dockerfile已配置使用node:18-alpine解决兼容性问题
   ```

2. **服务启动失败**
   ```bash
   # 检查环境变量配置
   ./deploy.sh status
   
   # 查看详细日志
   ./deploy.sh logs
   ```

3. **数据库连接失败**
   ```bash
   # 确保数据库服务正常启动
   docker-compose ps postgres
   
   # 检查数据库连接
   docker-compose exec postgres pg_isready
   ```

## 监控和维护

### 日志查看

```bash
# 查看所有服务日志
./deploy.sh logs

# 查看特定服务日志
./deploy.sh logs app
./deploy.sh logs postgres
./deploy.sh logs redis
```

### 数据备份

```bash
# 创建数据备份
./deploy.sh backup

# 备份文件位置
ls -la backups/
```

### 服务更新

```bash
# 更新镜像
./build-and-push.sh your-registry/kb-upload-genie new-version

# 更新环境变量中的镜像版本
# APP_IMAGE=your-registry/kb-upload-genie:new-version

# 重启服务
./deploy.sh restart
```

## 安全建议

1. **修改默认密码**: 确保修改数据库和Redis的默认密码
2. **使用HTTPS**: 在生产环境中配置SSL证书
3. **防火墙配置**: 只开放必要的端口
4. **定期备份**: 设置定期数据备份策略
5. **监控告警**: 配置服务监控和告警机制

## 技术支持

如遇到部署问题，请检查：

1. Docker和Docker Compose版本兼容性
2. 服务器资源是否充足（内存、磁盘空间）
3. 网络连接是否正常
4. 环境变量配置是否正确

更多技术细节请参考项目文档或提交Issue。