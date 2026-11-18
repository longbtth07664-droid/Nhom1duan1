# Đồng bộ code với main

Lỗi trước đây: đang làm việc trên nhánh `khanh`, file batch commit vào nhánh đó nhưng chạy `git push origin main`. Lệnh này đẩy nhánh main local cũ thay vì commit vừa tạo. Main trên GitHub cũng có cập nhật mới nên cần merge trước khi push.

Đã gộp cập nhật từ GitHub, giữ các module đăng nhập, bán vé, thanh toán và hóa đơn; bổ sung các file thống kê còn chưa theo dõi. Nhánh làm việc hiện tại là `main`.

## Các lần sau

Chạy `push_code_len_github.bat` từ thư mục dự án. File này gọi `scripts/sync-main.ps1`:

1. Kiểm tra đang ở main và không có merge dở dang.
2. Stage và commit các thay đổi code; không lấy target hay cấu hình IDE chưa theo dõi.
3. Pull main từ origin và merge cập nhật.
4. Push HEAD lên main; dừng ngay nếu bất kỳ bước nào lỗi.

Có thể đặt nội dung commit bằng PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-main.ps1 -Message "Mo ta thay doi"
```

Nếu có xung đột, xem `git status`, sửa các file bị đánh dấu rồi `git add` và `git commit` trước khi chạy lại. Script không tự force push.

`target/` là file Maven sinh ra; đã ngừng theo dõi để tránh xung đột file class/WAR. Build bằng `mvn package`, cấu hình Tomcat dùng artifact vừa build. File nguồn nằm trong `src/`.

Trước khi đồng bộ đã giữ nhánh dự phòng `codex/backup-khanh-before-sync-20261118` và hai stash chứa file build cũ. Chưa xóa các bản dự phòng này.
