package repository;

import entity.ThongKeReport;
import org.hibernate.Session;
import util.HibernateConfig;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

// Chỉ đọc dữ liệu bán hàng; không sửa giá, trạng thái hay tồn kho của module khác.
/* TRA CỨU HÀM: ThongKeRepository
 * JSP gửi form -> Servlet kiểm tra -> Repository đọc/ghi dữ liệu.
 * Ctrl+F "load(" để tìm phần xử lý.
 * Ctrl+F "query(" để tìm phần xử lý.
 * Ctrl+F "readDays(" để tìm phần xử lý.
 * Ctrl+F "readRanking(" để tìm phần xử lý.
 */
public class ThongKeRepository {
    // 1. ĐIỀU KIỆN CHUNG: chỉ lấy hóa đơn hoàn tất đã thanh toán.
    // EXISTS không nhân doanh thu khi hóa đơn có nhiều dòng thanh toán.
    private static final String PAID =
        " FROM HoaDon h WHERE h.NgayDat >= ? AND h.NgayDat < ? "
        + "AND h.TrangThai = N'Đã hoàn tất' "
        + "AND EXISTS (SELECT 1 FROM ThanhToan t WHERE t.MaDatVe=h.MaDatVe AND t.TrangThai=N'Thành công')";
    // [TK-VE-DA-BAN] Thanh toán ghi "Đã bán". Vé cũ vẫn dùng các trạng thái in/soát vé.
    private static final String VALID_TICKET = "v.TrangThai IN (N'Đã bán',N'Chưa in',N'Đã in',N'Đã soát vé',N'Đã check-in')";

    // 2. MỞ KẾT NỐI: dùng cấu hình Hibernate sẵn có của dự án.
    /** [ThongKeRepository-load] Đầu vào là khoảng ngày. Đọc số liệu ngày, xếp hạng phim và mặt hàng, chuẩn bị biểu đồ rồi trả ThongKeReport. */
    public ThongKeReport load(LocalDate from, LocalDate to) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.doReturningWork(new DocBaoCao(from, to));
        }
    }

    // 3. ĐỌC BÁO CÁO: bên truyền kết nối tự quản lý giao dịch của mình.
    // Tuyệt đối không commit, rollback, đóng kết nối hoặc đổi autoCommit tại đây.
    /** [ThongKeRepository-load] Đầu vào là khoảng ngày. Đọc số liệu ngày, xếp hạng phim và mặt hàng, chuẩn bị biểu đồ rồi trả ThongKeReport. */
    public ThongKeReport load(Connection connection, LocalDate from, LocalDate to) throws SQLException {
        ThongKeReport report = new ThongKeReport();
        readDays(connection, from, to, report);
        // true: top phim; false: top sản phẩm/combo.
        readRanking(connection, from, to, report, true);
        readRanking(connection, from, to, report, false);
        report.prepareChart();
        return report;
    }

    // 4. GẮN BỘ LỌC: truyền ngày bằng tham số, không ghép đầu vào vào SQL.
    /** [ThongKeRepository-query] Tạo PreparedStatement; gắn đầu ngày và đầu ngày kế tiếp ngày cuối. Dấu < lấy đủ mọi giờ của ngày kết thúc. */
    private PreparedStatement query(Connection connection, String sql, LocalDate from, LocalDate to) throws SQLException {
        PreparedStatement statement = connection.prepareStatement(sql);
        statement.setTimestamp(1, Timestamp.valueOf(from.atStartOfDay()));
        // Nửa khoảng [từ ngày, ngày sau đến ngày) bao gồm trọn ngày cuối.
        statement.setTimestamp(2, Timestamp.valueOf(to.plusDays(1).atStartOfDay()));
        statement.setQueryTimeout(20);
        return statement;
    }

    // 5. THỐNG KÊ THEO NGÀY: hóa đơn -> tổng vé, tổng món -> tổng từng ngày.
    /** [ThongKeRepository-readDays] Paid lọc hóa đơn đã trả tiền; Tickets/Items tổng hợp riêng theo hóa đơn; LEFT JOIN rồi GROUP BY ngày để không nhân doanh thu. */
    private void readDays(Connection connection, LocalDate from, LocalDate to, ThongKeReport report) throws SQLException {
        // Tổng hợp từng bảng chi tiết theo hóa đơn TRƯỚC khi nối để không nhân vé x món.
        String sql = "WITH Paid AS (SELECT h.MaDatVe,h.NgayDat,h.TongTien,COALESCE(h.TienGiam,0) AS TienGiam" + PAID + "), "
            + "Tickets AS (SELECT v.MaDatVe,COUNT_BIG(*) AS Qty,SUM(v.GiaVe) AS Amount FROM Ve v "
            + "JOIN Paid p ON p.MaDatVe=v.MaDatVe WHERE " + VALID_TICKET + " GROUP BY v.MaDatVe), "
            + "Items AS (SELECT d.MaDatVe,SUM(CAST(d.SoLuong AS BIGINT)) AS Qty,"
            + "SUM(CAST(d.SoLuong AS DECIMAL(18,0))*d.DonGia) AS Amount FROM ChiTietHoaDon d "
            + "JOIN Paid p ON p.MaDatVe=d.MaDatVe GROUP BY d.MaDatVe) "
            + "SELECT CAST(p.NgayDat AS DATE),SUM(p.TongTien),SUM(p.TienGiam),"
            + "SUM(COALESCE(v.Amount,0)),SUM(COALESCE(d.Amount,0)),COUNT_BIG(*),"
            + "SUM(COALESCE(v.Qty,0)),SUM(COALESCE(d.Qty,0)),"
            + "SUM(CAST(CASE WHEN p.TongTien+p.TienGiam<>COALESCE(v.Amount,0)+COALESCE(d.Amount,0) THEN 1 ELSE 0 END AS BIGINT)) "
            + "FROM Paid p LEFT JOIN Tickets v ON v.MaDatVe=p.MaDatVe LEFT JOIN Items d ON d.MaDatVe=p.MaDatVe "
            + "GROUP BY CAST(p.NgayDat AS DATE) ORDER BY CAST(p.NgayDat AS DATE)";
        Map<LocalDate, ThongKeReport.Day> values = new HashMap<>();
        try (PreparedStatement statement = query(connection, sql, from, to); ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                LocalDate date = rs.getDate(1).toLocalDate();
                // Các cột đúng theo thứ tự SELECT ở trên.
                BigDecimal revenue = rs.getBigDecimal(2);
                BigDecimal discount = rs.getBigDecimal(3);
                BigDecimal ticketValue = rs.getBigDecimal(4);
                BigDecimal productValue = rs.getBigDecimal(5);
                long invoices = rs.getLong(6);
                long tickets = rs.getLong(7);
                long items = rs.getLong(8);
                long mismatches = rs.getLong(9);
                ThongKeReport.Day day = new ThongKeReport.Day(date, revenue, discount,
                        ticketValue, productValue, invoices, tickets, items, mismatches);
                values.put(date, day);
            }
        }
        // Ngày không phát sinh vẫn có mặt trên biểu đồ và bảng.
        for (LocalDate date = from; !date.isAfter(to); date = date.plusDays(1)) {
            ThongKeReport.Day day = values.get(date);
            if (day == null) {
                day = new ThongKeReport.Day(date, BigDecimal.ZERO, BigDecimal.ZERO,
                        BigDecimal.ZERO, BigDecimal.ZERO, 0, 0, 0, 0);
            }
            report.addDay(day);
        }
    }

    // 6. XẾP HẠNG: lấy 10 phim hoặc mặt hàng có giá trị bán cao nhất.
    /** [ThongKeRepository-readRanking] films=true lấy top phim; false lấy top sản phẩm/combo. Dùng giá đã lưu lúc bán, sắp giảm dần và lấy 10 dòng. */
    private void readRanking(Connection connection, LocalDate from, LocalDate to, ThongKeReport report, boolean films) throws SQLException {
        String sql = "WITH Paid AS (SELECT h.MaDatVe" + PAID + ") ";
        if (films) {
            // Schema chỉ có Ve.MaSuat, không có phim chốt tại thời điểm bán.
            // Giao diện phải nói rõ đây là phân nhóm theo suất chiếu hiện tại.
            sql += "SELECT TOP (10) COALESCE(p.TenPhim,N'Phim không còn tồn tại'),N'Vé',COUNT_BIG(*),SUM(v.GiaVe) "
                + "FROM Ve v JOIN Paid h ON h.MaDatVe=v.MaDatVe LEFT JOIN SuatChieu s ON s.MaSuat=v.MaSuat "
                + "LEFT JOIN Phim p ON p.MaPhim=s.MaPhim WHERE " + VALID_TICKET
                + " GROUP BY s.MaPhim,p.TenPhim ORDER BY SUM(v.GiaVe) DESC,COUNT_BIG(*) DESC,s.MaPhim";
        } else {
            sql += "SELECT TOP (10) COALESCE(p.TenSP,cb.TenCombo,N'Mặt hàng không còn tồn tại'),"
                + "CASE WHEN d.MaCombo IS NULL THEN N'Sản phẩm' ELSE N'Combo' END,"
                + "SUM(CAST(d.SoLuong AS BIGINT)),SUM(CAST(d.SoLuong AS DECIMAL(18,0))*d.DonGia) "
                + "FROM ChiTietHoaDon d JOIN Paid h ON h.MaDatVe=d.MaDatVe "
                + "LEFT JOIN SanPham p ON p.MaSP=d.MaSP LEFT JOIN Combo cb ON cb.MaCombo=d.MaCombo "
                + "GROUP BY d.MaSP,d.MaCombo,p.TenSP,cb.TenCombo "
                + "ORDER BY SUM(CAST(d.SoLuong AS DECIMAL(18,0))*d.DonGia) DESC,d.MaSP,d.MaCombo";
        }
        try (PreparedStatement statement = query(connection, sql, from, to); ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                ThongKeReport.Ranking row = new ThongKeReport.Ranking(rs.getString(1),rs.getString(2),rs.getLong(3),rs.getBigDecimal(4));
                if (films) {
                    report.getFilms().add(row);
                } else {
                    report.getProducts().add(row);
                }
            }
        }
    }
    /** [TK-KETNOI] Hibernate gọi execute và đưa vào kết nối đang mở.
     * Lớp này giữ hai ngày lọc thay cho biểu thức lambda.
     * [TK-GIAO-DICH-DOC] Giữ cùng một giao dịch cho tổng quan và hai bảng xếp hạng.
     * SERIALIZABLE ngăn hóa đơn mới lọt vào giữa các truy vấn trong cùng báo cáo.
     */
    private class DocBaoCao implements org.hibernate.jdbc.ReturningWork<ThongKeReport> {
        private final LocalDate from;
        private final LocalDate to;

        DocBaoCao(LocalDate from, LocalDate to) {
            this.from = from;
            this.to = to;
        }

        @Override
        public ThongKeReport execute(Connection connection) throws SQLException {
            int mucCu = connection.getTransactionIsolation();
            boolean autoCommitCu = connection.getAutoCommit();
            try {
                connection.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
                connection.setAutoCommit(false);
                ThongKeReport report;
                try {
                    report = load(connection, from, to);
                    connection.commit();
                } catch (SQLException | RuntimeException e) {
                    connection.rollback();
                    throw e;
                }
                return report;
            } finally {
                connection.setAutoCommit(autoCommitCu);
                connection.setTransactionIsolation(mucCu);
            }
        }
    }
}
