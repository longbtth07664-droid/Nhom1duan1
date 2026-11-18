# Tương thích SQL QuanLyDatVeRapPhim — 18/11/2026

## Nguyên nhân và thay đổi

File SQL dùng `SanPham.MaSP`, `Combo.MaCombo` là `INT IDENTITY(1,1)`.
Code cũ ánh xạ hai khóa và các khóa trong `ChiTietCombo` thành chuỗi, tự cấp
`SP01`/`CB01`, nên thao tác lưu không khớp kiểu dữ liệu và cột IDENTITY.

- Đổi các khóa và lớp khóa ghép sang `Integer`; dùng `GenerationType.IDENTITY` cho sản phẩm và combo.
- Bỏ mọi truy vấn tự cấp mã `MAX`/`SUBSTRING`. Form thêm hiển thị “Tự động khi lưu”; mã từ form không quyết định mã được lưu.
- Lưu combo trước để lấy ID rồi gán ID đó vào các dòng chi tiết trong cùng giao dịch.
- Tìm kiếm mã số qua `cast(... as string)`; các thao tác đọc/sửa/xóa truyền khóa số.
- Giữ map chi tiết theo khóa `Integer` để form sửa chọn đúng sản phẩm.
- Chấp nhận `jpg`, `jpeg`, `png`, `webp`; ảnh `combo_solo.png`, `combo_couple.png` trong SQL mẫu sửa được. Đây là tên file có sẵn trên server, chưa phải chức năng tải ảnh lên.
- Không hiển thị danh sách sản phẩm trống khi truy vấn lỗi. Không cập nhật thành bản ghi mới nếu sản phẩm đã bị xóa; chặn xóa sản phẩm được tham chiếu ngay trong giao dịch.
- Kiểm tra giá sản phẩm trong giới hạn `DECIMAL(18,0)`, kể cả dạng số mũ.
- Đặt locale `vi_VN` tại 3 JSP để số tiền luôn có dấu phân cách hàng nghìn, kể cả khi trình duyệt không gửi ngôn ngữ.

## Thống kê

Các truy vấn thống kê hiện tại tương thích schema SQL được gửi. `TongTien` trong dữ liệu mẫu đã trừ giảm giá, nên không trừ `TienGiam` lần nữa.

Hai hóa đơn nằm ở **20/03/2026**. Mặc định trang chỉ xem từ đầu tháng hiện tại đến hôm nay; nếu xem tháng khác sẽ có doanh thu 0 đúng theo bộ lọc. Đã thêm nút **Năm nay**. Cũng có thể chọn từ ngày và đến ngày đều là `2026-03-20`.

| Chỉ tiêu của dữ liệu mẫu | Kết quả |
| --- | ---: |
| Hóa đơn | 2 |
| Vé | 2 |
| Số combo bán | 2 |
| Tiền vé trước giảm hóa đơn | 175.000đ |
| Tiền combo trước giảm hóa đơn | 185.000đ |
| Giảm giá hóa đơn | 16.000đ |
| Doanh thu sau giảm | **344.000đ** |

Không cần chạy lại file SQL để áp dụng sửa code. Build và triển khai lại WAR hoặc restart Tomcat với artifact mới trong `target/DuAnNhom1-1.0-SNAPSHOT`.

## Kiểm thử

- Maven package bằng JDK 17.
- Jasper biên dịch 3 JSP: quản lý combo, sản phẩm và thống kê, 0 lỗi.
- `tests/ComboValidationCheck.java`: kiểm tra đầu vào, ảnh PNG, mã tự tăng, số lượng và giới hạn tiền.
- `tests/CatalogIntegrationCheck.java`: dùng repository/Hibernate thật với bảng tạm SQL Server có khóa `INT IDENTITY`; kiểm tra thêm/sửa/xóa, khóa ghép, tìm kiếm, giá, tồn kho, dấu phiên bản, chặn xóa và rollback. Không sửa bảng nghiệp vụ.
- `tests/ThongKeIntegrationCheck.java`: dữ liệu kiểm thử có khóa INT, hai hóa đơn mẫu và các trường hợp thanh toán lặp, hóa đơn/vé hủy, nhiều chi tiết, ngày cuối, ngày trống, xếp hạng và bảo toàn giao dịch của bên gọi.
- `tests/WebSmokeCheck.java`: chạy Tomcat riêng trên cổng localhost ngẫu nhiên, đăng nhập tài khoản mẫu và đọc 8 trang/API; kiểm tra sản phẩm đã chọn khi sửa combo, tên ảnh PNG, JSON chi tiết và doanh thu mẫu.

Sau khi build, chạy các kiểm thử Java bằng JDK 17 từ thư mục dự án:

```powershell
$cp = 'target/classes;target/DuAnNhom1-1.0-SNAPSHOT/WEB-INF/lib/*;DUONG_DAN_TOMCAT/lib/*;DUONG_DAN_TOMCAT/bin/tomcat-juli.jar'
java '-Dfile.encoding=UTF-8' -cp $cp tests/ComboValidationCheck.java
java '-Dfile.encoding=UTF-8' -cp $cp tests/CatalogIntegrationCheck.java
java '-Dfile.encoding=UTF-8' -cp $cp tests/ThongKeIntegrationCheck.java
java '-Dfile.encoding=UTF-8' -cp $cp tests/WebSmokeCheck.java
```

Các kiểm thử SQL đọc cấu hình kết nối hiện có trong `HibernateConfig.java`. Kiểm thử web yêu cầu tài khoản và dữ liệu mẫu của file SQL được gửi. Báo cáo chi tiết quy tắc doanh thu ở [thong-ke.md](thong-ke.md).
