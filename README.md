# MangaDive - Ứng dụng đọc truyện tranh

MangaDive là một ứng dụng đọc truyện tranh Flutter hiện đại, được thiết kế với trải nghiệm người dùng tuyệt vời và hiệu suất cao.

## Cấu trúc cơ sở dữ liệu

Ứng dụng sử dụng Firebase Firestore với cấu trúc dữ liệu sau:

### 1. Collection: users/{userId}
- Thông tin người dùng cơ bản: email, username, experience, totalReadChapters, premium
- Cài đặt người dùng: theme, language, notification, reading preferences
- Subcollection:
  - reading_history: Lịch sử đọc truyện
  - follows: Danh sách truyện đang theo dõi
  - notifications: Thông báo cho người dùng
  - purchases: Lịch sử mua hàng

### 2. Collection: mangas/{mangaId}
- Thông tin truyện: title, description, coverImage, author, artist, status, genres
- Thống kê: totalViews, totalFollowers, averageRating, popularity_score
- Subcollection:
  - chapters: Các chapter của truyện
  - ratings: Đánh giá và review từ người dùng

### 3. Collection: categories/{categoryId}
- Thông tin thể loại: name, description, mangaCount

### 4. Collection: cache
- Cache danh sách truyện phổ biến, mới nhất, trending

## Tính năng chính

- **Quản lý người dùng**: Đăng ký, đăng nhập, chỉnh sửa thông tin, cài đặt
- **Duyệt truyện**: Xem truyện phổ biến, mới nhất, theo thể loại
- **Đọc truyện**: Hỗ trợ nhiều kiểu đọc (dọc, ngang, phải sang trái)
- **Theo dõi truyện**: Đánh dấu truyện yêu thích và nhận thông báo khi có chapter mới
- **Đánh giá truyện**: Xếp hạng và viết đánh giá cho truyện
- **Hệ thống truyện premium**: Mua và đọc truyện có tính phí
- **Thông báo**: Nhận thông báo khi có chapter mới hoặc cập nhật

## Cài đặt và chạy ứng dụng

### Yêu cầu
- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.17.0)
- Firebase project

### Bước 1: Clone mã nguồn
```bash
git clone https://github.com/yourusername/mangadive.git
cd mangadive
```

### Bước 2: Cài đặt dependencies
```bash
flutter pub get
```

### Bước 3: Kết nối Firebase
1. Tạo một project Firebase mới
2. Thêm ứng dụng Flutter vào project
3. Tải file `google-services.json` (Android) hoặc `GoogleService-Info.plist` (iOS)
4. Đặt các file này vào thư mục thích hợp

### Bước 4: Khởi tạo cơ sở dữ liệu Firestore
1. Chạy script database migration để thiết lập cấu trúc collections
2. Thêm dữ liệu mẫu nếu cần

### Bước 5: Chạy ứng dụng
```bash
flutter run
```

## Cấu trúc mã nguồn

```
lib/
  ├── constants/             # Các hằng số, đường dẫn collection
  ├── controllers/           # State management và business logic
  ├── models/                # Các mô hình dữ liệu
  ├── routes/                # Định nghĩa các routes
  ├── services/              # Services giao tiếp với Firebase
  ├── utils/                 # Tiện ích
  ├── view/                  # Giao diện người dùng
  │   ├── screens/           # Các màn hình
  │   ├── widgets/           # Các widget tái sử dụng
  │   └── themes/            # Định nghĩa theme
  └── main.dart              # Điểm khởi đầu ứng dụng
```

## Các model chính

- **User**: Thông tin người dùng và cài đặt
- **Manga**: Thông tin truyện
- **Chapter**: Thông tin chapter và trang
- **ReadingHistory**: Lịch sử đọc truyện
- **Follow**: Thông tin theo dõi truyện
- **UserNotification**: Thông báo cho người dùng
- **Purchase**: Thông tin giao dịch
- **Rating**: Đánh giá và nhận xét truyện
- **Category**: Thể loại truyện
- **CacheData**: Cache data để tối ưu hiệu suất

## Hướng dẫn phát triển

### Thêm truyện mới
1. Tạo document trong collection `mangas`
2. Thêm thông tin cơ bản: title, description, coverImage, v.v.
3. Thêm các chapter vào subcollection `chapters`

### Thêm thể loại mới
1. Tạo document trong collection `categories`
2. Thêm thông tin: name, description

### Cập nhật cấu trúc cơ sở dữ liệu
1. Cập nhật mô hình tương ứng trong `/models`
2. Cập nhật service trong `/services/firebase_service.dart`
3. Cập nhật controller liên quan

## Bảo trì

### Thanh lọc dữ liệu
- Sử dụng Cloud Functions để định kỳ xóa thông báo hết hạn
- Tối ưu cache để cải thiện hiệu suất

### Sao lưu dữ liệu
- Sử dụng tính năng sao lưu của Firebase Firestore
- Thiết lập lịch sao lưu tự động

## Liên hệ
Nếu bạn có bất kỳ câu hỏi nào, vui lòng liên hệ qua email: [your-email@example.com]

## License
Ứng dụng này được phân phối dưới giấy phép MIT.
