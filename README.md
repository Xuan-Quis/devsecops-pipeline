# Dự Án DevSecOps

## Tổng Quan
Dự án này thể hiện một pipeline DevSecOps hoàn chỉnh với các công cụ tích hợp để triển khai và quản lý ứng dụng một cách an toàn và tự động.

## Các Công Cụ Tích Hợp & Mục Đích Sử Dụng

### 🏗️ **Infrastructure as Code (Terraform)**
- **Mục đích**: Tự động hóa việc cung cấp hạ tầng AWS
- **Lợi ích**: 
  - Triển khai hạ tầng nhất quán và có thể lặp lại
  - Thay đổi hạ tầng được kiểm soát phiên bản
  - Giảm thiểu lỗi cấu hình thủ công

### 🐳 **Container Orchestration (Kubernetes/EKS)**
- **Mục đích**: Quản lý ứng dụng container hóa ở quy mô lớn
- **Lợi ích**:
  - Tính khả dụng cao và khả năng mở rộng
  - Tự động cân bằng tải và khám phá dịch vụ
  - Sử dụng tài nguyên hiệu quả

### 🔄 **GitOps & Continuous Deployment (ArgoCD)**
- **Mục đích**: Tự động hóa triển khai ứng dụng sử dụng Git làm nguồn chân lý
- **Lợi ích**:
  - Quản lý ứng dụng theo cách khai báo
  - Đồng bộ hóa tự động với Git repositories
  - Khả năng rollback và theo dõi kiểm toán

### 🔧 **CI/CD Pipeline (Jenkins)**
- **Mục đích**: Tự động hóa quy trình build, test và triển khai
- **Lợi ích**:
  - Kiểm tra chất lượng code tự động
  - Quy trình build và triển khai nhất quán
  - Tích hợp với các công cụ quét bảo mật

### 🛡️ **Tích Hợp Bảo Mật**
- **Mục đích**: Nhúng bảo mật xuyên suốt vòng đời phát triển
- **Lợi ích**:
  - Phát hiện lỗ hổng sớm
  - Tuân thủ các chính sách bảo mật
  - Giảm thiểu rủi ro bảo mật trong production

### 📊 **Giám Sát & Quan Sát**
- **Mục đích**: Theo dõi hiệu suất và sức khỏe ứng dụng
- **Lợi ích**:
  - Phát hiện vấn đề chủ động
  - Hiểu biết tối ưu hóa hiệu suất
  - Minh bạch hoạt động

## Cấu Trúc Dự Án
```
devsecops/
├── eks/                    # Cấu hình cluster EKS
├── Fullstack-Ecommerce-Web/ # Ứng dụng mẫu
├── Jenkins-Pipeline-Code/   # Định nghĩa pipeline CI/CD
├── Jenkins-Server-TF/      # Hạ tầng máy chủ Jenkins
└── kubernetes-manifest/    # Manifest triển khai Kubernetes
```
## Pipeline Backend DevSecOps

## Chi Tiết Các Giai Đoạn

### 1. **Development & Source Control**
- Developer push code lên Git repository
- Jenkins tự động trigger pipeline khi có thay đổi

### 2. **Build & Test Stage**
- **Code Checkout**: Lấy code từ Git
- **Maven Build**: Build ứng dụng Spring Boot
- **Unit Tests**: Chạy test cases
- **Code Quality**: Kiểm tra chất lượng code (SonarQube)

### 3. **Security Scanning**
- **Static Analysis**: Quét lỗ hổng trong code
- **Dependency Check**: Kiểm tra dependencies
- **Container Scan**: Quét bảo mật Docker image

### 4. **Container & Registry**
- **Docker Build**: Tạo container image
- **ECR Push**: Đẩy image lên AWS ECR
- **Image Security**: Quét bảo mật image

### 5. **Deployment**
- **EKS Deployment**: Triển khai lên Kubernetes cluster
- **ArgoCD Sync**: Đồng bộ với GitOps
- **Health Check**: Kiểm tra ứng dụng hoạt động

### 6. **Monitoring & Rollback**
- **Production Monitoring**: Giám sát ứng dụng
- **Auto Rollback**: Tự động rollback nếu có lỗi
- **Team Notification**: Thông báo cho team

## Công Cụ Sử Dụng

| Giai Đoạn | Công Cụ | Mục Đích |
|------------|---------|----------|
| Source Control | Git | Quản lý code |
| CI/CD | Jenkins | Tự động hóa pipeline |
| Build | Maven | Build ứng dụng Java |
| Testing | JUnit | Unit testing |
| Code Quality | SonarQube | Kiểm tra chất lượng |
| Security | OWASP ZAP | Quét bảo mật |
| Container | Docker | Containerization |
| Registry | AWS ECR | Lưu trữ images |
| Orchestration | Kubernetes/EKS | Quản lý containers |
| GitOps | ArgoCD | Continuous deployment |
| Monitoring | Prometheus/Grafana | Giám sát ứng dụng |

## Tính Năng Chính
- **Kiến Trúc Đa Tầng**: Frontend, Backend và Database
- **Bảo Mật Tự Động**: Tích hợp quét bảo mật và kiểm tra tuân thủ
- **Hạ Tầng Có Thể Mở Rộng**: Khả năng tự động mở rộng cho các tải khác nhau
- **Khôi Phục Sau Thảm Họa**: Cơ chế sao lưu và khôi phục
- **Sẵn Sàng Tuân Thủ**: Tích hợp sẵn khả năng bảo mật và kiểm toán
