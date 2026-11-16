package controller;

import entity.Phim;
import entity.TheLoai;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.PhimRepository;
import repository.TheLoaiRepository;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * Controller phục vụ màn hình Bán vé tại quầy (POS)
 * Quản lý chọn ngày, chọn phim và chuẩn bị dữ liệu cho suất chiếu & ghế ngồi.
 */
@WebServlet(name = "BanVeServlet", value = "/ban-ve")
public class BanVeServlet extends HttpServlet {

    private final PhimRepository phimRepo = new PhimRepository();
    private final TheLoaiRepository theLoaiRepo = new TheLoaiRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // 1. Xử lý ngày chiếu (mặc định là hôm nay)
        LocalDate today = LocalDate.now();
        String ngayChieuStr = req.getParameter("ngayChieu");
        LocalDate selectedNgay = today;
        if (ngayChieuStr != null && !ngayChieuStr.trim().isEmpty()) {
            try {
                selectedNgay = LocalDate.parse(ngayChieuStr.trim());
            } catch (Exception ignored) {
                selectedNgay = today;
            }
        }

        // 2. Tạo danh sách 7 ngày liên tiếp để hiển thị thanh chọn ngày nhanh
        List<DateItem> dateTabs = new ArrayList<>();
        DateTimeFormatter dayOfWeekFmt = DateTimeFormatter.ofPattern("EEE");
        DateTimeFormatter dayFmt = DateTimeFormatter.ofPattern("dd/MM");
        for (int i = 0; i < 7; i++) {
            LocalDate d = today.plusDays(i);
            String label = (i == 0) ? "Hôm nay" : ((i == 1) ? "Ngày mai" : "Thứ " + (d.getDayOfWeek().getValue() + 1));
            if (d.getDayOfWeek().getValue() == 7) {
                label = "Chủ nhật";
            }
            dateTabs.add(new DateItem(d.toString(), label, d.format(dayFmt), d.equals(selectedNgay)));
        }

        // 3. Xử lý tìm kiếm và lọc phim
        String keyword = req.getParameter("keyword");
        String maTheLoai = req.getParameter("maTheLoai");

        List<Phim> listPhim;
        if ((keyword != null && !keyword.trim().isEmpty()) || (maTheLoai != null && !maTheLoai.trim().isEmpty())) {
            listPhim = phimRepo.search(keyword, maTheLoai);
        } else {
            listPhim = phimRepo.getAll();
        }

        // 4. Kiểm tra mã phim được chọn (nếu có)
        String maPhimStr = req.getParameter("maPhim");
        Phim selectedPhim = null;
        if (maPhimStr != null && !maPhimStr.trim().isEmpty()) {
            try {
                selectedPhim = phimRepo.getOne(Integer.parseInt(maPhimStr.trim()));
            } catch (NumberFormatException ignored) {}
        }

        // 5. Đẩy dữ liệu sang giao diện
        req.setAttribute("dateTabs", dateTabs);
        req.setAttribute("selectedNgay", selectedNgay.toString());
        req.setAttribute("listPhim", listPhim);
        req.setAttribute("listTheLoai", theLoaiRepo.getAll());
        req.setAttribute("keyword", keyword != null ? keyword.trim() : "");
        req.setAttribute("selectedTheLoai", maTheLoai != null ? maTheLoai.trim() : "");
        req.setAttribute("selectedPhim", selectedPhim);

        req.getRequestDispatcher("/ban-ve/view.jsp").forward(req, resp);
    }

    /**
     * DTO đơn giản đại diện cho một tab ngày chiếu trên thanh chọn ngày
     */
    public static class DateItem {
        private final String dateValue;  // YYYY-MM-DD
        private final String dayLabel;   // Hôm nay, Ngày mai, Thứ 3...
        private final String dateDisplay;// 15/11, 16/11...
        private final boolean active;

        public DateItem(String dateValue, String dayLabel, String dateDisplay, boolean active) {
            this.dateValue = dateValue;
            this.dayLabel = dayLabel;
            this.dateDisplay = dateDisplay;
            this.active = active;
        }

        public String getDateValue() { return dateValue; }
        public String getDayLabel() { return dayLabel; }
        public String getDateDisplay() { return dateDisplay; }
        public boolean isActive() { return active; }
    }
}
