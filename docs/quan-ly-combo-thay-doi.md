# Quản lý sản phẩm và combo — thay đổi ngày 14/11/2026

> Đây là ghi chép của phiên bản cũ dùng mã chuỗi. Bản sửa tương thích SQL `INT IDENTITY` ngày 18/11/2026, hỗ trợ ảnh PNG và kiểm thử mới được ghi ở [sql-compatibility.md](sql-compatibility.md).

## Phạm vi
Chỉ sửa 6 file nguồn: ComboServlet, SanPhamServlet, ComboRepository, SanPhamRepository, quanLyCombo.jsp, quanLySanPham.jsp.
Giữ cấu trúc Servlet → Repository → Entity → JSP. Không thay đổi entity, cấu hình chung, bảng dữ liệu hoặc module khác trong lượt sửa này.
Các file target/ là kết quả build và kiểm tra.

## Các yêu cầu đã thực hiện
- Thêm mới sản phẩm/combo luôn đang kinh doanh/đang bán; server cũng áp dụng mặc định.
- Mã SP/CB được gợi ý khi tải form; cấp lại dưới khóa SQL Server lúc lưu để tránh hai yêu cầu đồng thời cùng mã.
- Truy cập JSP trực tiếp được chuyển qua controller để nạp dữ liệu và mã.
- Loại/đơn vị có lựa chọn hướng dẫn; chọn loại gợi ý đơn vị, vẫn dùng danh mục hiện tại.
- Hiển thị tồn kho; số lượng phải là số nguyên từ 1 đến tồn kho. Server đọc lại trạng thái, giá và tồn kho trong giao dịch lưu.
- Tạo combo không trừ tồn kho.
- Tìm theo mã/tên, hỗ trợ không dấu; lọc không làm mất món đã chọn.
- Mức giảm 0%, 10%, 20%, 50%; giá = tổng giá lẻ nhân (100 - mức giảm)/100, làm tròn HALF_UP đến đồng.
- Server tính giá, không tin giá gửi từ trình duyệt.
- Form sửa mặc định giữ giá đã lưu; thay đổi thành phần tự chuyển sang tính lại không giảm, quản lý có thể chọn mức giảm mới.
- Tách danh sách sản phẩm cho form thêm/sửa, tránh đưa sản phẩm ngừng bán vào danh sách thêm mới.
- Giữ bản nhập trong tab khi lỗi lưu; báo rõ lỗi số lượng/trạng thái.
- Dấu phiên bản phát hiện một người lưu form cũ sau khi người khác sửa combo.
- Xóa combo qua POST có token phiên; chặn khi có hóa đơn và báo nếu mã đã mất.
- Hoàn tác trước khi đóng session; lỗi đọc dữ liệu combo không giả làm danh sách trống.
- Bỏ phản hồi chi tiết cũ nếu người dùng đã mở combo khác.
- Tên ảnh phải .jpg; đây vẫn là tên file ảnh được đặt sẵn trên server.

## Giới hạn cần biết
- Chỉ lưu giá sau giảm trong cột GiaCombo hiện có, chưa có cột lưu tỷ lệ giảm; không suy đoán tỷ lệ từ giá combo cũ.
- Cách sinh mã MAX + 1 vẫn có thể tái sử dụng mã lớn nhất đã bị xóa. Muốn đảm bảo không tái sử dụng qua mọi lần khởi động cần thống nhất sequence hoặc cơ chế lưu lịch sử với nhóm.
- Chưa thay đổi nghiệp vụ hóa đơn, trừ kho khi bán, lưu lịch sử giá/thành phần. Cần phối hợp với người phụ trách bán hàng trước khi thay đổi.
- Chưa áp đặt quy tắc tên combo duy nhất, bắt buộc cả bắp lẫn nước, hay tự sinh mô tả vì nhóm chưa chốt.
- Chưa chạy thêm/sửa/xóa với database thực tế hoặc kiểm thử trình duyệt đầy đủ.

## Kiểm tra
- Maven package offline: BUILD SUCCESS, 25 file Java.
- Tomcat Jasper: biên dịch cả hai JSP với 0 lỗi.
- JavaScript: tính giá giảm, số lượng 0/lẻ/vượt kho, sản phẩm ngừng bán, tìm không dấu/mã/không có kết quả.
- Java: mặc định trạng thái server của cả sản phẩm và combo, không dùng giá khách gửi, kiểm tra đuôi ảnh, số lượng sai, chống dòng trùng, dấu phiên bản.
