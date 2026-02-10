# Cấp quyền thực thi cho script
`
chmod +x install.sh
`

# Chạy cài đặt Docker, Postgres và Keycloak
`
sudo ./install.sh
`


# Khởi chạy tất cả container ở chế độ chạy ngầm
`
docker compose up -d
`

Kiểm tra API
`
curl -I http://localhost:5860/actuator/health
`

Service,Endpoint Test
Product Service,
`
curl -i http://localhost:5860/api/product/health
`
Shopping Cart
`

curl -i http://localhost:5860/api/shopping-cart/health
`
User Service,
`
curl -i http://localhost:5860/api/user/health
`