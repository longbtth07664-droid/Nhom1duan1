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
@WebServlet(name = "ThongKeServlet", urlPatterns = {"/thong-ke"})
public class ThongKeServlet extends HttpServlet {
    private final ThongKeRepository repository = new ThongKeRepository();

    // 1. KIỂM TRA NGÀY: không đảo ngày, không xem quá 366 ngày mỗi lần.
    /** [ThongKeServlet-validateRange] Chặn ngày đảo ngược, ngoài giới hạn và khoảng dài hơn 366 ngày trước khi truy vấn. */
    public static void validateRange(LocalDate from, LocalDate to) {
        if (from.getYear() < 1900 || to.getYear() > 9998 || to.isBefore(from)) {
            throw new IllegalArgumentException("Ngày bắt đầu phải trước hoặc bằng ngày kết thúc (từ năm 1900).");
        }
        if (ChronoUnit.DAYS.between(from, to) > 365) {
            throw new IllegalArgumentException("Mỗi lần xem tối đa 366 ngày. Vui lòng thu hẹp khoảng thời gian.");
        }
    }

    @Override
    /** [ThongKeServlet-doGet] Nhận yêu cầu mở trang. Đọc bộ lọc, gọi hàm xử lý rồi chuyển dữ liệu sang JSP. */
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

        try {
            // 3. ĐỌC BỘ LỌC: lần đầu mở trang dùng đầu tháng đến hôm nay.
            String start = request.getParameter("from");
            String end = request.getParameter("to");
            if (start != null || end != null) {
                if (start == null || end == null || start.isBlank() || end.isBlank()) {
                    throw new IllegalArgumentException("Vui lòng nhập đầy đủ từ ngày và đến ngày.");
                }
                try {
                    from = LocalDate.parse(start);
                    to = LocalDate.parse(end);
                } catch (DateTimeParseException e) {
                    throw new IllegalArgumentException("Ngày không hợp lệ. Vui lòng chọn lại.");
                }
            }

            // 4. LẤY SỐ LIỆU: chỉ truy vấn sau khi ngày đã hợp lệ.
            validateRange(from, to);
            ThongKeReport report = repository.load(from, to);
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
        request.getRequestDispatcher("/WEB-INF/views/thongKe.jsp").forward(request, response);
    }

    // Các mốc ngày dành cho nút Hôm nay, 7 ngày qua, Tháng này, Tháng trước.
    /** [ThongKeServlet-setQuickDates] Tính các mốc ngày cho nút Hôm nay, 7 ngày, tháng, năm theo ngày Việt Nam. */
    private void setQuickDates(HttpServletRequest request, LocalDate today) {
        request.setAttribute("today", today.toString());
        request.setAttribute("weekStart", today.minusDays(6).toString());
        request.setAttribute("monthStart", today.withDayOfMonth(1).toString());
        request.setAttribute("yearStart", today.withDayOfYear(1).toString());
        request.setAttribute("previousStart", today.minusMonths(1).withDayOfMonth(1).toString());
        request.setAttribute("previousEnd", today.withDayOfMonth(1).minusDays(1).toString());
    }
}
