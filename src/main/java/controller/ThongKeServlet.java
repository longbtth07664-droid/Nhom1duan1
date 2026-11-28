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

    // [TK-KIEM-TRA] Đoạn nào chặn chọn ngày ngược hoặc khoảng ngày quá dài?
    // validateRange kiểm tra mốc năm và thứ tự ngày. Chênh lệch tối đa 365 ngày là 366 ngày tính cả hai đầu.
    public static void validateRange(LocalDate from, LocalDate to) {
        if (from.getYear() < 1900 || to.getYear() > 9998 || to.isBefore(from)) {
            throw new IllegalArgumentException("Ngày bắt đầu phải trước hoặc bằng ngày kết thúc (từ năm 1900).");
        }
        if (ChronoUnit.DAYS.between(from, to) > 365) {
            throw new IllegalArgumentException("Mỗi lần xem tối đa 366 ngày. Vui lòng thu hẹp khoảng thời gian.");
        }
    }

    // [TK-KIEMTRA-NHOM] Đoạn nào giới hạn bộ lọc theo tháng hoặc năm?
    // Chế độ tháng xem từng tháng trong một năm. Chế độ năm xem tối đa 10 năm, tính cả năm đầu và năm cuối.
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
    // [TK-BO-LOC] Bấm lọc Thống kê theo ngày, tháng hoặc năm thì code nào chạy?
    // doGet xác định khoảng ngày từ mode, kiểm tra khoảng rồi gọi repository.load và groupBy.
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
            // [TK-CHON-KHOANG] Theo tháng lấy cả năm đã chọn. Theo năm lấy trọn các năm trong khoảng.
            // Theo ngày dùng from/to người dùng nhập, mặc định từ đầu tháng đến hôm nay.
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

            // [TK-GOI-BAO-CAO] load lấy dữ liệu theo ngày, groupBy gom lại nếu đang xem tháng hoặc năm.
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

    // [TK-MOC-NGAY] Các mốc của nút lọc nhanh được tính ở đâu?
    // setQuickDates dùng ngày hiện tại theo giờ Việt Nam. 7 ngày qua bắt đầu từ hôm nay trừ 6 ngày.
    private void setQuickDates(HttpServletRequest request, LocalDate today) {
        request.setAttribute("today", today.toString());
        request.setAttribute("weekStart", today.minusDays(6).toString());
        request.setAttribute("monthStart", today.withDayOfMonth(1).toString());
        request.setAttribute("yearStart", today.withDayOfYear(1).toString());
        request.setAttribute("previousStart", today.minusMonths(1).withDayOfMonth(1).toString());
        request.setAttribute("previousEnd", today.withDayOfMonth(1).minusDays(1).toString());
    }
    // [TK-DOC-NAM] Năm được đọc và kiểm tra ở đâu?
    // Không gửi tham số thì dùng mặc định. Đã gửi thì phải là số nguyên từ 1900 đến 9998.
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

    // [TK-DOC-NGAY] Chuỗi ngày trên form được chuyển thành kiểu ngày ở đâu?
    // docNgay chặn giá trị trống và dùng LocalDate.parse để đọc ngày dạng yyyy-MM-dd.
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
