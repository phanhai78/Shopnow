#!/bin/bash

# Dừng nếu có lỗi
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}>>> Bắt đầu thiết lập GitLab Runner (Docker Executor)...${NC}"

# 1. Kiểm tra Docker
if ! command -v docker &> /dev/null; then
    echo "Docker chưa được cài đặt. Vui lòng cài Docker trước."
    exit 1
fi

# 2. Tạo thư mục làm việc
RUNNER_DIR="/opt/gitlab-runner"
mkdir -p $RUNNER_DIR
cd $RUNNER_DIR

# 3. Yêu cầu nhập thông tin từ người dùng
echo -e "${YELLOW}--- CẤU HÌNH KẾT NỐI ---${NC}"
read -p "Nhập GitLab URL (Mặc định: https://gitlab.com/): " GITLAB_URL
GITLAB_URL=${GITLAB_URL:-"https://gitlab.com/"}

echo -e "${YELLOW}Vui lòng vào GitLab -> Settings -> CI/CD -> Runners để lấy Token.${NC}"
read -p "Nhập Registration Token: " REG_TOKEN

if [ -z "$REG_TOKEN" ]; then
  echo "Lỗi: Token không được để trống!"
  exit 1
fi

read -p "Nhập Description cho Runner (vd: docker-runner-01): " RUNNER_DESC
RUNNER_DESC=${RUNNER_DESC:-"docker-runner"}


echo -e "${GREEN}>>> Đang tạo file docker-compose.yml...${NC}"
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  gitlab-runner:
    image: gitlab/gitlab-runner:latest
    container_name: gitlab-runner
    restart: always
    volumes:
      - ./config:/etc/gitlab-runner
      - /var/run/docker.sock:/var/run/docker.sock
EOF

echo -e "${GREEN}>>> Đang đăng ký Runner với GitLab...${NC}"

docker compose run --rm gitlab-runner register \
  --non-interactive \
  --url "$GITLAB_URL" \
  --token "$REG_TOKEN" \
  --executor "docker" \
  --docker-image "docker:24-git" \
  --description "$RUNNER_DESC" \
  --maintenance-note "Free-form maintainer notes" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"


sed -i 's/concurrent = 1/concurrent = 2/' ./config/config.toml


echo -e "${GREEN}>>> Đang khởi động GitLab Runner Service...${NC}"
docker compose up -d

echo -e "${GREEN}>>> Cài đặt hoàn tất!${NC}"
echo "Runner: $RUNNER_DESC đã sẵn sàng."
echo "File cấu hình nằm tại: $RUNNER_DIR/config/config.toml"