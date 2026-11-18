# Thống kê kinh doanh

Cập nhật 18/11/2026: thêm nút **Năm nay**. Dữ liệu SQL mẫu nằm ở 20/03/2026; chọn ngày đó để kiểm tra doanh thu **344.000đ**. Xem [sql-compatibility.md](sql-compatibility.md) về tương thích khóa INT và các kiểm thử mới.

Vào **Menu quản lý → Tổng quan** (`/thong-ke`). Chỉ tài khoản quản lý được xem. Triển khai lại WAR hoặc cập nhật artifact trên Tomcat sau khi sửa mã.

## Các file của chức năng

- `controller/ThongKeServlet.java`: nhận và kiểm tra khoảng ngày, trả lỗi rõ ràng khi dữ liệu không tải được.
- `repository/ThongKeRepository.java`: truy vấn chỉ đọc, tổng hợp theo ngày và xếp hạng.
- `entity/ThongKeReport.java`: dữ liệu báo cáo; không phải entity Hibernate và không tạo bảng.
- `WEB-INF/views/thongKe.jsp`: giao diện, không truy cập trực tiếp từ trình duyệt.
- `assets/css/thongKe.css`: định dạng riêng của báo cáo.
- `tests/ThongKeIntegrationCheck.java`: kiểm tra nghiệp vụ trên SQL Server bằng bảng tạm trong phiên kết nối.

Hai file dùng chung chỉ bổ sung tích hợp: `menuadmin.jsp` thêm liên kết, `AuthFilter.java` thêm đường dẫn dành cho quản lý. Không cần cập nhật cấu trúc SQL, giá, tồn kho hay dữ liệu của các chức năng khác.

## Quy tắc tính

- Lọc theo **ngày lập hóa đơn**, không phải ngày chiếu hay ngày thanh toán. Mặc định từ đầu tháng đến hôm nay theo giờ Việt Nam. Theo ngày tối đa 366 ngày; theo tháng lấy đủ 12 tháng của một năm; theo năm tối đa 10 năm. Lấy trọn ngày cuối.
- Chỉ tính hóa đơn `Đã hoàn tất` có ít nhất một thanh toán `Thành công`. Nhiều lần thanh toán không làm nhân doanh thu.
- Doanh thu sau giảm lấy từ `HoaDon.TongTien`; không trừ `TienGiam` thêm lần nữa.
- Vé hợp lệ: `Chưa in`, `Đã in`, `Đã soát vé`. Giá trị vé dùng `Ve.GiaVe` đã lưu khi bán.
- Giá trị sản phẩm/combo dùng `ChiTietHoaDon.SoLuong * DonGia`; không lấy giá hiện tại trong danh mục. Một combo là một đơn vị bán.
- Xếp hạng theo giá trị bán trước giảm giá hóa đơn. Không tự phân bổ giảm giá giữa phim và sản phẩm.
- Các bảng chi tiết được tổng hợp riêng trước khi nối; tránh nhân số vé với số món.
- Nếu tổng tiền sau giảm cộng tiền giảm không bằng chi tiết hợp lệ, hiện cảnh báo đối chiếu; không tự sửa hóa đơn.
- Có ngày không giao dịch, trạng thái rỗng và thông báo lỗi kết nối riêng. Không biến lỗi truy vấn thành doanh thu bằng 0.
- Đây là báo cáo bán hàng, không phải lợi nhuận hay sổ kế toán hoàn tiền. Chưa có dữ liệu giá vốn để tính lợi nhuận.

## Phạm vi và giao dịch đọc

- Bỏ `SERIALIZABLE` trên kết nối riêng của trang thống kê, dùng `READ_COMMITTED` và khôi phục mức cô lập trước khi trả kết nối. Không dùng `NOLOCK`; không thay đổi cấu hình database dùng chung. Mức này giảm việc giữ khóa nhưng không bảo đảm mọi truy vấn hoàn toàn không chờ nhau.
- Hàm `load(Connection, ...)` chỉ đọc; không tự commit, rollback, đóng kết nối hay thay đổi cấu hình kết nối do bên gọi cung cấp. Khi có lỗi, bên gọi tự quyết định xử lý giao dịch.
- Các truy vấn tổng quan và xếp hạng không còn nằm trong một giao dịch SERIALIZABLE. Nếu có giao dịch đồng thời, các phần có thể đọc tại các thời điểm khác nhau; giao diện nhắc tải lại trước khi đối chiếu. Báo cáo này không phải bản chốt sổ tại một thời điểm.
- Bảng phim được ghi rõ là phân nhóm theo suất chiếu hiện tại. Schema chưa lưu phim tại thời điểm bán vé, nên không thể khôi phục lịch sử sau khi suất chiếu đã đổi phim chỉ bằng code thống kê. Muốn khắc phục triệt để cần nhóm thống nhất lưu phim lúc bán hoặc chặn đổi phim của suất đã có vé. Lần sửa này không sửa module suất chiếu và không tạo trigger hay bảng mới.
- Chưa có luồng hoàn tiền hoàn chỉnh để xác định số tiền hoàn; không tự suy đoán và khấu trừ doanh thu.

## Kiểm chứng

Đã biên dịch Java, đóng gói Maven và biên dịch JSP bằng Jasper của Tomcat 10.1. Kiểm thử SQL dùng chính truy vấn repository với bảng tạm: thanh toán lặp, nhiều vé/món cùng hóa đơn, hóa đơn hủy/chưa trả tiền, vé hủy, ranh giới ngày, ngày trống, xếp hạng, đối chiếu và trung bình. Không chèn dữ liệu thử vào bảng nghiệp vụ.

Đã bổ sung kiểm thử giao dịch của bên gọi: thay đổi chưa commit vẫn rollback được sau khi đọc báo cáo; khi truy vấn lỗi, thay đổi của bên gọi vẫn còn để bên gọi tự xử lý. Kiểm thử cũng chặn mọi thao tác tự đổi cấu hình hoặc đóng kết nối trong hàm đọc.

Chạy kiểm thử SQL sau khi build bằng JDK 17 (chỉnh đường dẫn Tomcat theo máy):

```powershell
java '-Dfile.encoding=UTF-8' -cp 'target/classes;target/DuAnNhom1-1.0-SNAPSHOT/WEB-INF/lib/*;DUONG_DAN_TOMCAT/lib/servlet-api.jar' tests/ThongKeIntegrationCheck.java
```

Kiểm thử lấy cấu hình kết nối hiện tại từ `HibernateConfig.java`. Máy cần truy cập được SQL Server của dự án. Dữ liệu thật lúc kiểm tra chưa có hóa đơn, nên màn hình thực tế sẽ hiện trạng thái chưa có giao dịch; không thêm số liệu giả vào báo cáo.

## Chế độ nhóm số liệu

Chọn Ngày để nhập từ/đến ngày; chọn Tháng để nhập năm; chọn Năm để nhập từ/đến năm. Biểu đồ và bảng chi tiết tự đổi nhãn tương ứng. Tổng doanh thu, số hóa đơn, số vé, giảm giá, trung bình và xếp hạng đều dùng đúng phạm vi được chọn. Tháng/năm không có giao dịch vẫn hiện 0.

Repository tổng hợp từng hóa đơn rồi từng ngày bằng SQL. `ThongKeReport.groupBy` cộng lại các ngày bằng vòng lặp và Map để thành tháng/năm. Không sửa dữ liệu bán hàng, không chạy truy vấn riêng cho từng kỳ. Kiểm thử bổ sung: 12 tháng, nhiều năm, kỳ trống, năm nhuận, tổng và xếp hạng giữ nguyên, bộ lọc sai trả HTTP 400.