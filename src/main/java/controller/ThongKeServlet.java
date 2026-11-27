package controller;

import entity.ThongKeReport;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.ThongKeRepository;
import java.io.IOException;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;

// THỐNG KÊ: nhận bộ lọc ngày, lấy báo cáo và chuyển dữ liệu sang JSP.
// Tra cứu chức năng: docs/TRA_CUU_COMBO_SAN_PHAM_THONG_KE.txt
@WebServlet(name = "ThongKeServlet", urlPatterns = {"/thong-ke"})
public class ThongKeServlet extends HttpServlet {
    private final ThongKeRepository repository = new ThongKeRepository();

    // 1. KIỂM TRA NGÀY: không đảo ngày, không xem quá 366 ngày mỗi lần.
    // [TK-KIEM-TRA] Giới hạn ngày tối đa 366 ngày, tháng trong một năm, năm tối đa 10 năm.
    public static void validateRange(LocalDate from, LocalDate to) {
        if (from.getYear() < 1900 || to.getYear() > 9998 || to.isBefore(from)) {
            throw new IllegalArgumentException("Ngày bắt đầu phải trước hoặc bằng ngày kết thúc (từ năm 1900).");
        }
        if (ChronoUnit.DAYS.between(from, to) > 365) {
            throw new IllegalArgumentException("Mỗi lần xem tối đa 366 ngày. Vui lòng thu hẹp khoảng thời gian.");
        }
    }

    /** [TK-KIEMTRA-NHOM] Mỗi chế độ có giới hạn riêng để báo cáo dễ đọc. */
    public static void validateRange(LocalDate from, LocalDate to, String mode) {
        if ("day".equals(mode)) {
            validateRange(from, to);
        } else if ("month".equals(mode) || "year".equals(mode)) {
            if (from.getYear() < 1900 || to.getYear() > 9998 || to.isBefore(from))
                throw new IllegalArgumentException("Khoảng năm không hợp lệ (1900–9998).");
            if ("month".equals(mode) && from.getYear() != to.getYear())
                throw new IllegalArgumentException("Theo tháng chỉ xem một năm mỗi lần.");
            if (to.getYear() - from.getYear() > 9)
                throw new IllegalArgumentException("Theo năm xem tối đa 10 năm mỗi lần.");
        } else {
            throw new IllegalArgumentException("Chế độ thống kê không hợp lệ.");
        }
    }

    @Override
    // [TK-BO-LOC] Đọc chế độ ngày/tháng/năm, kiểm tra khoảng thời gian, lấy báo cáo và forward JSP.
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 2. CHUẨN BỊ: tiếng Việt và không lưu báo cáo cũ trong bộ nhớ đệm.
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        LocalDate today = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDate from = today.withDayOfMonth(1);
        LocalDate to = today;
        setQuickDates(request, today);
        String mode = request.getParameter("mode");
        if (mode == null) mode = "day";
        request.setAttribute("mode", mode);
        request.setAttribute("selectedYear", today.getYear());
        request.setAttribute("startYear", today.getYear() - 4);
        request.setAttribute("endYear", today.getYear());
        String periodName = "ngày";

        try {
            // 3. ĐỌC BỘ LỌC: lần đầu mở trang dùng đầu tháng đến hôm nay.
            if ("month".equals(mode)) {
                int year = docNam(request, "year", today.getYear());
                request.setAttribute("selectedYear", year);
                from = LocalDate.of(year, 1, 1);
                to = LocalDate.of(year, 12, 31);
                periodName = "tháng";
            } else if ("year".equals(mode)) {
                int first = docNam(request, "startYear", today.getYear() - 4);
                int last = docNam(request, "endYear", today.getYear());
                request.setAttribute("startYear", first);
                request.setAttribute("endYear", last);
                from = LocalDate.of(first, 1, 1);
                to = LocalDate.of(last, 12, 31);
                periodName = "năm";
            } else if (request.getParameter("from") != null || request.getParameter("to") != null) {
                from = docNgay(request.getParameter("from"));
                to = docNgay(request.getParameter("to"));
            }

            // 4. LẤY SỐ LIỆU: chỉ truy vấn sau khi ngày đã hợp lệ.
            validateRange(from, to, mode);
            ThongKeReport report = repository.load(from, to).groupBy(mode);
            request.setAttribute("report", report);
        } catch (IllegalArgumentException e) {
            // Sai bộ lọc: hiển thị lý do để người dùng sửa lại.
            response.setStatus(400);
            request.setAttribute("error", e.getMessage());
        } catch (Exception | ExceptionInInitializerError e) {
            // Lỗi dữ liệu/kết nối phải báo lỗi, không hiển thị doanh thu giả bằng 0.
            log("Không tải được báo cáo thống kê", e);
            response.setStatus(503);
            request.setAttribute("error",
                    "Chưa tải được thống kê. Vui lòng kiểm tra kết nối và các bảng bán hàng rồi thử lại.");
        }

        // 5. HIỂN THỊ: giữ lại khoảng ngày đã chọn trên form.
        request.setAttribute("from", from.toString());
        request.setAttribute("to", to.toString());
        request.setAttribute("periodName", periodName);
        request.getRequestDispatcher("/WEB-INF/views/thongKe.jsp").forward(request, response);
    }

    // Các mốc ngày dành cho nút Hôm nay, 7 ngày qua, Tháng này, Tháng trước.
    // [TK-MOC-NGAY] Tạo ngày cho các nút lọc nhanh theo múi giờ Việt Nam.
    private void setQuickDates(HttpServletRequest request, LocalDate today) {
        request.setAttribute("today", today.toString());
        request.setAttribute("weekStart", today.minusDays(6).toString());
        request.setAttribute("monthStart", today.withDayOfMonth(1).toString());
        request.setAttribute("yearStart", today.withDayOfYear(1).toString());
        request.setAttribute("previousStart", today.minusMonths(1).withDayOfMonth(1).toString());
        request.setAttribute("previousEnd", today.withDayOfMonth(1).minusDays(1).toString());
    }
    // [TK-DOC-NAM] Ô năm trống hoặc sai định dạng phải báo lỗi trước khi tạo LocalDate.
    private int docNam(HttpServletRequest request, String tenO, int macDinh) {
        String value = request.getParameter(tenO);
        if (value == null) return macDinh;
        try {
            int year = Integer.parseInt(value);
            if (year < 1900 || year > 9998)
                throw new IllegalArgumentException("Khoảng năm không hợp lệ (1900–9998).");
            return year;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Năm phải là số nguyên hợp lệ.");
        }
    }

    // [TK-DOC-NGAY] Đọc đúng định dạng yyyy-MM-dd từ input type=date.
    private LocalDate docNgay(String value) {
        if (value == null || value.isBlank())
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ từ ngày và đến ngày.");
        try {
            return LocalDate.parse(value);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Ngày không hợp lệ. Vui lòng chọn lại.");
        }
    }

}
