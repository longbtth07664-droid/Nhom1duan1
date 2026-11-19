# Bản đồ code để học và trình bày

Luồng chung: JSP (form) → Servlet (đọc/kiểm tra request) → Repository (truy vấn/lưu) → Entity hoặc Report (dữ liệu) → JSP (hiển thị). Ctrl+Shift+F tìm mã trong ngoặc vuông bên dưới; Ctrl+F tìm tên hàm. Các mã ổn định hơn số dòng khi bạn sửa code.

| Mã tìm kiếm | File và dòng | Hàm | Giải thích |
|---|---|---|---|
| `ComboServlet-doGet` | [controller/ComboServlet.java:34](../src/main/java/controller/ComboServlet.java#L34) | `doGet` | Nhận yêu cầu mở trang. Đọc bộ lọc, gọi hàm xử lý rồi chuyển dữ liệu sang JSP. |
| `ComboServlet-doPost` | [controller/ComboServlet.java:72](../src/main/java/controller/ComboServlet.java#L72) | `doPost` | Nhận dữ liệu form gửi lên. Xác định action và gọi chức năng thêm, sửa hoặc xóa. |
| `ComboServlet-hienThiDanhSach` | [controller/ComboServlet.java:104](../src/main/java/controller/ComboServlet.java#L104) | `hienThiDanhSach` | Lấy danh sách từ repository, đặt vào request bằng setAttribute, forward sang JSP. |
| `ComboServlet-moFormSua` | [controller/ComboServlet.java:126](../src/main/java/controller/ComboServlet.java#L126) | `moFormSua` | Lấy bản hiện có và danh sách cho form; đặt editSP/editCombo vào request để JSP mở hộp sửa. |
| `ComboServlet-luuCombo` | [controller/ComboServlet.java:166](../src/main/java/controller/ComboServlet.java#L166) | `luuCombo` | Đọc form và mức giảm, gọi repository.save. Chuyển hướng sau lưu để tải lại trang không gửi trùng form. |
| `ComboServlet-traChiTietJson` | [controller/ComboServlet.java:191](../src/main/java/controller/ComboServlet.java#L191) | `traChiTietJson` | Đọc chi tiết theo mã, tạo JSON trả cho fetch trên giao diện. Escape chuỗi để JSON không hỏng. |
| `ComboServlet-docThongTinCombo` | [controller/ComboServlet.java:223](../src/main/java/controller/ComboServlet.java#L223) | `docThongTinCombo` | Đọc thông tin chung; kiểm tra mã, tên, trạng thái và tên ảnh. Giá gửi từ trình duyệt không quyết định giá lưu. |
| `ComboServlet-docDanhSachChiTiet` | [controller/ComboServlet.java:272](../src/main/java/controller/ComboServlet.java#L272) | `docDanhSachChiTiet` | Đọc các checkbox ctMaSP; lấy số lượng và ghi chú theo mã; dùng Map loại mã lặp rồi trả danh sách. |
| `SanPhamServlet-doGet` | [controller/SanPhamServlet.java:23](../src/main/java/controller/SanPhamServlet.java#L23) | `doGet` | Nhận yêu cầu mở trang. Đọc bộ lọc, gọi hàm xử lý rồi chuyển dữ liệu sang JSP. |
| `SanPhamServlet-doPost` | [controller/SanPhamServlet.java:67](../src/main/java/controller/SanPhamServlet.java#L67) | `doPost` | Nhận dữ liệu form gửi lên. Xác định action và gọi chức năng thêm, sửa hoặc xóa. |
| `SanPhamServlet-hienThiDanhSach` | [controller/SanPhamServlet.java:94](../src/main/java/controller/SanPhamServlet.java#L94) | `hienThiDanhSach` | Lấy danh sách từ repository, đặt vào request bằng setAttribute, forward sang JSP. |
| `SanPhamServlet-moFormSua` | [controller/SanPhamServlet.java:124](../src/main/java/controller/SanPhamServlet.java#L124) | `moFormSua` | Lấy bản hiện có và danh sách cho form; đặt editSP/editCombo vào request để JSP mở hộp sửa. |
| `SanPhamServlet-docThongTinSanPham` | [controller/SanPhamServlet.java:168](../src/main/java/controller/SanPhamServlet.java#L168) | `docThongTinSanPham` | Đọc tên, loại, đơn vị, giá, tồn kho, trạng thái. Kiểm tra bắt buộc, danh mục và giới hạn cột rồi tạo SanPham; sai trả null. |
| `ThongKeServlet-validateRange` | [controller/ThongKeServlet.java:23](../src/main/java/controller/ThongKeServlet.java#L23) | `validateRange` | Chặn ngày đảo ngược, ngoài giới hạn và khoảng dài hơn 366 ngày trước khi truy vấn. |
| `ThongKeServlet-doGet` | [controller/ThongKeServlet.java:50](../src/main/java/controller/ThongKeServlet.java#L50) | `doGet` | Nhận yêu cầu mở trang. Đọc bộ lọc, gọi hàm xử lý rồi chuyển dữ liệu sang JSP. |
| `ThongKeServlet-setQuickDates` | [controller/ThongKeServlet.java:137](../src/main/java/controller/ThongKeServlet.java#L137) | `setQuickDates` | Tính các mốc ngày cho nút Hôm nay, 7 ngày, tháng, năm theo ngày Việt Nam. |
| `ComboRepository-getAll` | [repository/ComboRepository.java:20](../src/main/java/repository/ComboRepository.java#L20) | `getAll` | SELECT toàn bộ danh mục, sắp xếp theo mã. Session tự đóng khi ra khỏi try. |
| `ComboRepository-getOne` | [repository/ComboRepository.java:30](../src/main/java/repository/ComboRepository.java#L30) | `getOne` | Chuyển mã đầu vào sang số rồi tìm theo khóa chính. Không có bản ghi thì trả null. |
| `ComboRepository-search` | [repository/ComboRepository.java:43](../src/main/java/repository/ComboRepository.java#L43) | `search` | Ghép điều kiện khi có từ khóa/trạng thái. setParameter truyền giá trị riêng để tránh ghép đầu vào vào SQL. |
| `ComboRepository-getChiTiet` | [repository/ComboRepository.java:80](../src/main/java/repository/ComboRepository.java#L80) | `getChiTiet` | Lấy các dòng ChiTietCombo và tải sẵn SanPham để JSP dùng được sau khi đóng Session. |
| `ComboRepository-save` | [repository/ComboRepository.java:100](../src/main/java/repository/ComboRepository.java#L100) | `save` | Bắt đầu giao dịch; kiểm tra phiên bản và các món; tính giá; lưu combo rồi lưu chi tiết; commit. Có lỗi thì rollback. |
| `ComboRepository-fingerprint` | [repository/ComboRepository.java:156](../src/main/java/repository/ComboRepository.java#L156) | `fingerprint` | Ghép nội dung combo và chi tiết theo thứ tự mã rồi băm SHA-256. So với dấu lúc mở form để phát hiện người khác đã sửa. |
| `ComboRepository-delete` | [repository/ComboRepository.java:175](../src/main/java/repository/ComboRepository.java#L175) | `delete` | Kiểm tra dữ liệu tham chiếu trước khi xóa. Các bước ghi cùng giao dịch để lỗi không để lại dữ liệu dở dang. |
| `SanPhamRepository-getAll` | [repository/SanPhamRepository.java:20](../src/main/java/repository/SanPhamRepository.java#L20) | `getAll` | SELECT toàn bộ danh mục, sắp xếp theo mã. Session tự đóng khi ra khỏi try. |
| `SanPhamRepository-getOne` | [repository/SanPhamRepository.java:42](../src/main/java/repository/SanPhamRepository.java#L42) | `getOne` | Chuyển mã đầu vào sang số rồi tìm theo khóa chính. Không có bản ghi thì trả null. |
| `SanPhamRepository-search` | [repository/SanPhamRepository.java:52](../src/main/java/repository/SanPhamRepository.java#L52) | `search` | Ghép điều kiện khi có từ khóa/trạng thái. setParameter truyền giá trị riêng để tránh ghép đầu vào vào SQL. |
| `SanPhamRepository-add` | [repository/SanPhamRepository.java:78](../src/main/java/repository/SanPhamRepository.java#L78) | `add` | Đặt ID null để SQL Server tự tăng; persist ghi bản mới; commit xác nhận, rollback khi lỗi. |
| `SanPhamRepository-update` | [repository/SanPhamRepository.java:97](../src/main/java/repository/SanPhamRepository.java#L97) | `update` | Tìm và khóa bản hiện có trước khi merge. Ngăn sửa bản đã bị xóa thành một bản mới. |
| `SanPhamRepository-isSanPhamUsed` | [repository/SanPhamRepository.java:137](../src/main/java/repository/SanPhamRepository.java#L137) | `isSanPhamUsed` | Đếm tham chiếu trong ChiTietCombo và ChiTietHoaDon. Có ít nhất một tham chiếu thì không cho xóa. |
| `SanPhamRepository-delete` | [repository/SanPhamRepository.java:154](../src/main/java/repository/SanPhamRepository.java#L154) | `delete` | Kiểm tra dữ liệu tham chiếu trước khi xóa. Các bước ghi cùng giao dịch để lỗi không để lại dữ liệu dở dang. |
| `ThongKeRepository-load` | [repository/ThongKeRepository.java:25](../src/main/java/repository/ThongKeRepository.java#L25) | `load` | Đầu vào là khoảng ngày. Đọc số liệu ngày, xếp hạng phim và mặt hàng, chuẩn bị biểu đồ rồi trả ThongKeReport. |
| `ThongKeRepository-load` | [repository/ThongKeRepository.java:34](../src/main/java/repository/ThongKeRepository.java#L34) | `load` | Đầu vào là khoảng ngày. Đọc số liệu ngày, xếp hạng phim và mặt hàng, chuẩn bị biểu đồ rồi trả ThongKeReport. |
| `ThongKeRepository-query` | [repository/ThongKeRepository.java:46](../src/main/java/repository/ThongKeRepository.java#L46) | `query` | Tạo PreparedStatement; gắn đầu ngày và đầu ngày kế tiếp ngày cuối. Dấu < lấy đủ mọi giờ của ngày kết thúc. |
| `ThongKeRepository-readDays` | [repository/ThongKeRepository.java:57](../src/main/java/repository/ThongKeRepository.java#L57) | `readDays` | Paid lọc hóa đơn đã trả tiền; Tickets/Items tổng hợp riêng theo hóa đơn; LEFT JOIN rồi GROUP BY ngày để không nhân doanh thu. |
| `ThongKeRepository-readRanking` | [repository/ThongKeRepository.java:102](../src/main/java/repository/ThongKeRepository.java#L102) | `readRanking` | films=true lấy top phim; false lấy top sản phẩm/combo. Dùng giá đã lưu lúc bán, sắp giảm dần và lấy 10 dòng. |
| `ThongKeReport-addDay` | [entity/ThongKeReport.java:25](../src/main/java/entity/ThongKeReport.java#L25) | `addDay` | Thêm một ngày vào danh sách và cộng từng chỉ tiêu vào tổng báo cáo; ngày đã được SQL tổng hợp. |
| `ThongKeReport-getAverage` | [entity/ThongKeReport.java:48](../src/main/java/entity/ThongKeReport.java#L48) | `getAverage` | Doanh thu chia số hóa đơn, làm tròn đến đồng. Nếu không có hóa đơn trả 0 để tránh chia cho 0. |
| `ThongKeReport-prepareChart` | [entity/ThongKeReport.java:91](../src/main/java/entity/ThongKeReport.java#L91) | `prepareChart` | Hai vòng lặp: tìm doanh thu lớn nhất rồi đổi mỗi ngày sang phần trăm chiều cao cột. |

## Giao diện và JavaScript
- Combo: `src/main/webapp/quanLyCombo.jsp`. Tìm `addComboModal` (thêm), `editComboModal` (sửa), `tinhTongGiaLe` (giá xem trước), `validateComboForm` (kiểm tra trình duyệt), `xemChiTietCombo` (fetch JSON), `xoaCombo` (POST xóa). Giá cuối cùng vẫn do repository tính.
- Sản phẩm: `src/main/webapp/quanLySanPham.jsp`. Tìm `action`, `editSP`, `dsSanPham`: form gửi action=add/update; danh sách dùng c:forEach; thông báo đọc tham số msg.
- Tổng quan: `src/main/webapp/WEB-INF/views/thongKe.jsp`. Tìm `tkFrom`, `tkTo` (lọc ngày), `report.revenue` (doanh thu), `report.days` (biểu đồ/bảng), `report.films`, `report.products` (xếp hạng). CSS riêng ở assets/css/thongKe.css.

## Câu hỏi thường gặp
- Vì sao dùng Integer cho mã? SQL là INT IDENTITY. @GeneratedValue trong Combo.java/SanPham.java để database cấp mã. ChiTietComboId.java là khóa ghép (mã combo, mã sản phẩm).
- Vì sao dùng BigDecimal? Tính tiền chính xác; cộng bằng add, nhân bằng multiply, chia bằng divide. Giá combo = tổng (giá sản phẩm × số lượng) × (100 − giảm)/100; HALF_UP làm tròn đến đồng.
- Vì sao có transaction? Lưu combo và các món phải cùng thành công; commit xác nhận, rollback hoàn tác. try-with-resources tự đóng Session/ResultSet, tránh quên đóng.
- Vì sao vẫn dùng Hibernate, khóa và SHA-256? Đây là cơ chế đang bảo đảm chức năng cũ. Vòng lặp, điều kiện và hàm nghiệp vụ được làm rõ; bỏ các cơ chế này sẽ thay đổi khả năng chống sửa đè và tính toàn vẹn dữ liệu.
- Doanh thu tính thế nào? Chỉ hóa đơn hoàn tất có thanh toán thành công; SUM(TongTien) đã sau giảm. Không trừ TienGiam lần hai. EXISTS tránh nhân tiền khi có nhiều thanh toán.
- Vì sao tổng hợp vé và món trước khi JOIN? Một hóa đơn 2 vé × 3 món có thể tạo 6 dòng khi nối trực tiếp. Tổng hợp từng bảng trước giữ đúng tổng tiền và số lượng.
- Bộ dữ liệu mẫu ngày 20/03/2026: 2 hóa đơn, 2 vé, 2 combo; vé 175.000, combo 185.000, giảm 16.000, doanh thu 344.000đ. Chọn đúng ngày hoặc Năm nay.
- Phân quyền ở filter/AuthFilter.java; cấu hình kết nối ở util/HibernateConfig.java. Token combo kiểm tra trong ComboServlet.doPost; version so sánh trong ComboRepository.save.

## Bổ sung thống kê Ngày – Tháng – Năm

- `controller/ThongKeServlet.java`: tìm `[TK-BOLOC]` để xem đọc chế độ và chuyển năm thành khoảng ngày đầy đủ; `[TK-KIEMTRA-NHOM]` kiểm tra tối đa 366 ngày / một năm theo tháng / 10 năm theo năm.
- `entity/ThongKeReport.java`: tìm `[TK-NHOM]`, hàm `groupBy`. Duyệt từng ngày, lấy ngày đầu tháng hoặc đầu năm làm khóa Map, cộng các chỉ tiêu vào cùng nhóm; kỳ trống vẫn có dòng 0. Không truy vấn lại cho mỗi tháng/năm.
- `WEB-INF/views/thongKe.jsp`: tìm `[TK-GIAODIEN]` và `doiCheDoThongKe`. Chọn chế độ sẽ hiện ô nhập tương ứng, ẩn và vô hiệu hóa ô không dùng; server vẫn kiểm tra độc lập. Biểu đồ/bảng đọc cùng report đã gộp.
- Vì sao tổng tiền không đổi sau gộp? Mỗi ngày chỉ thuộc đúng một tháng và một năm. `addDay` cộng lại các chỉ tiêu; xếp hạng giữ cùng bộ lọc, trung bình lấy tổng tiền chia tổng hóa đơn (không lấy trung bình của các trung bình).
- Theo tháng chọn 2026: 12 dòng 01/2026–12/2026. Theo năm chọn 2025–2026: 2 dòng. Theo ngày chọn 20/03/2026: doanh thu mẫu 344.000đ. Các nút nhanh ghi rõ năm nay là 12 tháng; tháng này/tháng trước vẫn là chi tiết ngày.

## Tra cứu các quy tắc nghiệp vụ

Trong IntelliJ, dùng **Ctrl+Shift+F** tìm mã ghi chú dưới đây.

| Mã tìm kiếm | File và hàm | Cách giải thích |
|---|---|---|
| `SP-CHONG-GHI-DE` | [SanPhamRepository.java](../src/main/java/repository/SanPhamRepository.java), `update` | Mở form lấy dấu dữ liệu gốc. Khi lưu, khóa dòng và so sánh với dữ liệu mới nhất. Ví dụ tồn kho từ 20 giảm còn 12 sau khi bán thì form cũ bị từ chối. |
| `SP-POST`, `SP-XOA` | [SanPhamServlet.java](../src/main/java/controller/SanPhamServlet.java), `doPost` và [quanLySanPham.jsp](../src/main/webapp/quanLySanPham.jsp), `xoaSP` | Form gửi POST kèm token phiên. Sau đó repository kiểm tra sản phẩm còn được tham chiếu trong combo hoặc hóa đơn trước khi xóa. |
| `CB-GIA`, `CB-NGUNG-BAN` | [ComboRepository.java](../src/main/java/repository/ComboRepository.java), `kiemTraVaTinhTongGiaLe` và [quanLyCombo.jsp](../src/main/webapp/quanLyCombo.jsp), `validateComboForm` | Combo ngừng bán được giữ công thức khi hết nguyên liệu. Khi bật bán lại, từng món phải còn kinh doanh và đủ số lượng. |
| `CB-GIU-GIA` | [quanLyCombo.jsp](../src/main/webapp/quanLyCombo.jsp), sự kiện `input` trong bảng chọn món | Sửa ghi chú giữ nguyên lựa chọn giá. Đổi món hoặc số lượng mới chuyển từ chế độ giữ giá sang tính lại. |
| `TK-VE-DA-BAN`, `TK-GIAO-DICH-DOC` | [ThongKeRepository.java](../src/main/java/repository/ThongKeRepository.java), `VALID_TICKET` và `DocBaoCao.execute` | Tính cả vé có trạng thái `Đã bán` và `Đã check-in`. Tổng quan, xếp hạng phim và xếp hạng mặt hàng đọc trong cùng giao dịch. |

Các quy tắc của quản lý combo áp dụng khi lưu danh mục. Kiểm tra trạng thái và tồn kho tại quầy thuộc luồng bán vé và thanh toán. Thống kê còn phụ thuộc vào lịch sử liên kết vé với phim và dữ liệu hoàn tiền.
