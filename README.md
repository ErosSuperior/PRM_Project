# PRM Project - Hệ thống quản lý và đặt dịch vụ gia đình

## 0. Tổng quan chức năng đã hoàn thiện

- Quản lý danh mục dịch vụ (CRUD, tìm kiếm/lọc, xác nhận xóa, thông báo rõ ràng)
- Quản lý gói dịch vụ (CRUD, chọn danh mục, tìm kiếm/lọc, xác nhận xóa, thông báo rõ ràng)
- Quản lý người dùng (CRUD, kích hoạt/vô hiệu hóa, tìm kiếm/lọc, xác nhận vô hiệu hóa, thông báo rõ ràng)
- Đặt lịch dịch vụ, phân công thợ, cập nhật trạng thái đơn hàng
- Đánh giá, phản hồi, tự động tính điểm trung bình thợ qua trigger DB
- Xác thực JWT, phân quyền admin/worker/customer
- Giao diện Flutter hiện đại, xác thực token cho mọi API quản trị
- Thông báo thành công/thất bại rõ ràng cho mọi thao tác quản trị

## 0.1. Hướng dẫn sử dụng nhanh

### Backend
- Chạy project PRM_Backend_Server bằng Visual Studio hoặc dotnet CLI
- Đảm bảo connection string trỏ đúng SQL Server, đã chạy full_setup.sql để tạo DB
- Swagger UI: http://localhost:5000/swagger để test API

### Mobile App (Flutter)
- Mở thư mục Flutter/ trên VS Code hoặc Android Studio
- Chạy lệnh `flutter pub get` để cài dependencies
- Chạy app trên thiết bị/emulator: `flutter run`
- Đăng nhập bằng tài khoản mẫu trong DB (admin@homeservice.com / Demo123!)

### Tài khoản mẫu
- Admin: admin@homeservice.com / Demo123!
- Worker: worker@homeservice.com / Demo123!
- Customer: customer@homeservice.com / Demo123!

## 0.2. Các tính năng quản trị nổi bật

- Tìm kiếm/lọc nhanh danh mục, gói dịch vụ, user
- Xác nhận thao tác nguy hiểm (xóa, vô hiệu hóa) bằng dialog cảnh báo
- Thông báo rõ ràng khi thao tác thành công/thất bại
- Chọn danh mục khi thêm/sửa gói dịch vụ
- Tự động làm mới danh sách sau mỗi thao tác CRUD

## 0.3. Lưu ý triển khai
- Không sửa đổi cấu trúc DB nếu không cần thiết, mọi logic tuân thủ full_setup.sql
- Token JWT phải được truyền trong header Authorization cho mọi API quản trị
- Đảm bảo quyền truy cập phù hợp (admin mới thao tác được các chức năng quản trị)


## 1. Mục tiêu dự án
PRM Project là hệ thống quản lý và đặt dịch vụ gia đình, giúp kết nối khách hàng với các thợ/nhà cung cấp dịch vụ một cách nhanh chóng, tiện lợi. Dự án gồm hai thành phần chính:
- **Backend**: Xây dựng bằng ASP.NET Core, cung cấp API cho ứng dụng di động và quản lý toàn bộ logic nghiệp vụ, xác thực, phân quyền, xử lý đơn hàng, đánh giá, thanh toán...
- **Mobile App**: Ứng dụng Flutter đa nền tảng (Android/iOS), giao diện thân thiện, cho phép khách hàng đặt dịch vụ, quản lý lịch sử, đánh giá thợ, và cho phép thợ nhận/quản lý đơn hàng.
- **Database**: Sử dụng SQL Server để lưu trữ dữ liệu tập trung, đảm bảo an toàn và toàn vẹn dữ liệu.

## 2. Các thành phần chính
- **Backend (PRM_Backend_Server)**: API RESTful, xác thực JWT, quản lý người dùng, dịch vụ, đơn hàng, đánh giá, thanh toán...
- **Database**: Thiết kế theo mô hình quan hệ, sử dụng stored procedures, triggers để tự động hóa các nghiệp vụ như tính điểm đánh giá, kiểm tra toàn vẹn dữ liệu.
- **Mobile App (Flutter)**: Giao diện người dùng, gọi API, quản lý trạng thái, lưu trữ token an toàn bằng flutter_secure_storage.

## 3. Công nghệ sử dụng
- **Ngôn ngữ:**
    - Backend: C# (.NET 8.0)
    - Frontend: Dart (Flutter SDK)
    - Database: T-SQL (SQL Server)
- **Framework & Thư viện:**
    - ASP.NET Core Web API
    - Entity Framework Core (ORM)
    - Microsoft.AspNetCore.Authentication.JwtBearer (xác thực)
    - Flutter SDK, http, provider, flutter_secure_storage
- **Khác:**
    - Swagger UI (OpenAPI) cho tài liệu hóa và test API
    - SQL Server Management Studio (quản lý CSDL)
-   **JWT (JSON Web Token):** Sau khi đăng nhập, Client nhận được một Access Token. Token này được đặt trong Header (`Authorization: Bearer <token>`) cho mọi yêu cầu API cần quyền truy cập.

### 4.2. Quy trình đặt lịch (Booking Flow)
1.  Khách hàng duyệt danh sách Category và chọn Package phù hợp.
2.  Khách hàng chọn ngày giờ, địa chỉ và tạo `Booking`.
3.  Admin/Hệ thống gán Thợ (Worker) cho đơn hàng.
4.  Thợ cập nhật trạng thái đơn hàng khi bắt đầu (`in_progress`) và khi hoàn thành (`completed`).

### 4.3. Đánh giá và Phản hồi (Rating & Feedback)
-   Sau khi đơn hàng hoàn thành, Khách hàng gửi `Rating`.
-   Hệ thống sử dụng **Stored Procedures** hoặc **Triggers** tại DB để tính toán lại `AverageRating` cho Thợ một cách tự động, giúp giảm tải cho ứng dụng và đảm bảo độ chính xác.

## 5. Các công nghệ chủ chốt (Technological Stack)
-   **Ngôn ngữ:** C# (Backend), Dart (Frontend), T-SQL (Database).
-   **Framework:** .NET 8.0, Flutter SDK.
-   **Thư viện xác thực:** Microsoft.AspNetCore.Authentication.JwtBearer.
-   **ORM:** Entity Framework Core (SQL Server Provider).
-   **Giao diện API:** Swagger UI (OpenAPI) hỗ trợ testing và tài liệu hóa.
