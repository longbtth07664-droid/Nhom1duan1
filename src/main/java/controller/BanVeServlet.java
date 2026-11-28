package controller;

import entity.Combo;
import entity.Ghe;
import entity.Phim;
import entity.SanPham;
import entity.SuatChieu;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.ComboRepository;
import repository.GheRepository;
import repository.PhimRepository;
import repository.SanPhamRepository;
import repository.SuatChieuRepository;
import repository.TheLoaiRepository;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * Controller phục vụ màn hình Bán vé tại quầy (POS)
 * Mô hình tối ưu cho rạp chiếu phim:
 * - Bước 1: Ngày chiếu + Các phim có lịch chiếu trong ngày kèm luôn danh sách khung giờ chiếu
 * - Bước 2: Chọn ghế ngồi trên sơ đồ trực quan của phòng chiếu
 * - Bước 3: Chọn Combo bắp nước (F&B) & tổng kết hóa đơn
 */
@WebServlet(name = "BanVeServlet", value = "/ban-ve")
public class BanVeServlet extends HttpServlet {

    private final PhimRepository phimRepo = new PhimRepository();
    private final TheLoaiRepository theLoaiRepo = new TheLoaiRepository();
    private final SuatChieuRepository suatChieuRepo = new SuatChieuRepository();
    private final GheRepository gheRepo = new GheRepository();
    private final ComboRepository comboRepo = new ComboRepository();
    private final SanPhamRepository sanPhamRepo = new SanPhamRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // 1. Xác định ngày chiếu (mặc định hôm nay)
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

        // 2. Tạo danh sách 5 - 7 ngày liên tiếp hiển thị trên thanh chọn ngày
        List<DateItem> dateTabs = new ArrayList<>();
        DateTimeFormatter dayFmt = DateTimeFormatter.ofPattern("dd/MM");
        for (int i = 0; i < 7; i++) {
            LocalDate d = today.plusDays(i);
            String label = (i == 0) ? "Hôm nay" : ((i == 1) ? "Ngày mai" : "Thứ " + (d.getDayOfWeek().getValue() + 1));
            if (d.getDayOfWeek().getValue() == 7) {
                label = "Chủ nhật";
            }
            dateTabs.add(new DateItem(d.toString(), label, d.format(dayFmt), d.equals(selectedNgay)));
        }

        // 3. Lấy tất cả suất chiếu của ngày được chọn và gom nhóm theo từng Phim
        List<SuatChieu> allSuatInDay = suatChieuRepo.getByNgay(selectedNgay);
        String keyword = req.getParameter("keyword");
        String kwLower = (keyword != null) ? keyword.trim().toLowerCase() : "";

        // Dùng Map giữ thứ tự xuất hiện của phim
        Map<Integer, MovieScheduleItem> scheduleMap = new LinkedHashMap<>();
        for (SuatChieu sc : allSuatInDay) {
            Phim p = sc.getPhim();
            if (p == null) continue;

            // Chỉ hiển thị phim đang chiếu và suất chiếu chưa bị hủy/đóng bán
            String ttPhim = p.getTrangThai() != null ? p.getTrangThai().trim() : "";
            if (!"Đang chiếu".equalsIgnoreCase(ttPhim)) {
                continue;
            }
            String ttSuat = sc.getTrangThai() != null ? sc.getTrangThai().trim() : "";
            if ("Đã hủy".equalsIgnoreCase(ttSuat) || "Đã đóng bán".equalsIgnoreCase(ttSuat)) {
                continue;
            }

            // Nếu có từ khóa tìm kiếm tên phim thì lọc
            if (!kwLower.isEmpty() && !p.getTenPhim().toLowerCase().contains(kwLower)) {
                continue;
            }

            MovieScheduleItem item = scheduleMap.computeIfAbsent(p.getMaPhim(), k -> new MovieScheduleItem(p));
            item.addSuatChieu(sc);
        }

        List<MovieScheduleItem> movieSchedules = new ArrayList<>(scheduleMap.values());

        // 4. Kiểm tra Suất chiếu và Phim đang chọn (nếu có)
        String maSuatStr = req.getParameter("maSuat");
        SuatChieu selectedSuat = null;
        Phim selectedPhim = null;
        Map<String, List<Ghe>> mapHangGhe = new LinkedHashMap<>();
        List<Integer> bookedSeatIds = new ArrayList<>();

        if (maSuatStr != null && !maSuatStr.trim().isEmpty()) {
            try {
                selectedSuat = suatChieuRepo.getOne(Integer.parseInt(maSuatStr.trim()));
                if (selectedSuat != null) {
                    selectedPhim = selectedSuat.getPhim();
                    if (selectedSuat.getPhongChieu() != null) {
                        // Tải sơ đồ ghế của phòng chiếu
                        List<Ghe> listGhe = gheRepo.getAllByPhong(selectedSuat.getPhongChieu().getMaPhong());
                        for (Ghe g : listGhe) {
                            String hang = g.getHangGhe().toUpperCase();
                            mapHangGhe.computeIfAbsent(hang, k -> new ArrayList<>()).add(g);
                        }
                        // Lấy các ghế đã bán
                        bookedSeatIds = suatChieuRepo.getBookedSeatIds(selectedSuat.getMaSuat());
                    }
                }
            } catch (NumberFormatException ignored) {}
        } else {
            String maPhimStr = req.getParameter("maPhim");
            if (maPhimStr != null && !maPhimStr.trim().isEmpty()) {
                try {
                    selectedPhim = phimRepo.getOne(Integer.parseInt(maPhimStr.trim()));
                } catch (NumberFormatException ignored) {}
            }
        }

        // 5. Tải danh sách Combo bắp nước đang kinh doanh
        List<Combo> listCombo = comboRepo.search(null, "Đang bán");
        if (listCombo.isEmpty()) {
            listCombo = comboRepo.getAll();
        }

        // Tải danh sách Sản phẩm lẻ (Bắp / Nước / Đồ ăn vặt đang kinh doanh)
        List<SanPham> listSanPham = Collections.emptyList();
        try {
            listSanPham = sanPhamRepo.getAllDangKinhDoanh();
            if (listSanPham == null || listSanPham.isEmpty()) {
                listSanPham = sanPhamRepo.getAll();
            }
        } catch (Exception ex) {
            System.err.println("Không tải được danh sách sản phẩm lẻ: " + ex.getMessage());
        }

        // 6. Xác định bước (1: Phim & Suất, 2: Chọn ghế, 3: Chọn combo)
        String stepParam = req.getParameter("step");
        int currentStep = 1;
        if (stepParam != null) {
            try {
                currentStep = Integer.parseInt(stepParam);
            } catch (NumberFormatException ignored) {}
        } else {
            if (selectedSuat != null) {
                currentStep = 2; // đã có suất chiếu -> mở ngay bước chọn ghế
            } else {
                currentStep = 1; // chưa chọn suất -> bước chọn phim & suất
            }
        }

        // 7. Đẩy dữ liệu ra giao diện JSP
        req.setAttribute("dateTabs", dateTabs);
        req.setAttribute("selectedNgay", selectedNgay.toString());
        req.setAttribute("movieSchedules", movieSchedules);
        req.setAttribute("totalMoviesInDay", movieSchedules.size());
        req.setAttribute("keyword", keyword != null ? keyword.trim() : "");
        req.setAttribute("selectedPhim", selectedPhim);
        req.setAttribute("selectedSuat", selectedSuat);
        req.setAttribute("mapHangGhe", mapHangGhe);
        req.setAttribute("bookedSeatIds", bookedSeatIds);
        req.setAttribute("listCombo", listCombo);
        req.setAttribute("listSanPham", listSanPham);
        req.setAttribute("currentStep", currentStep);

        req.getRequestDispatcher("/ban-ve/view.jsp").forward(req, resp);
    }

    /**
     * DTO đại diện cho một bộ phim kèm tất cả suất chiếu của phim đó trong ngày
     */
    public static class MovieScheduleItem {
        private final Phim phim;
        private final List<SuatChieu> suatChieus = new ArrayList<>();

        public MovieScheduleItem(Phim phim) {
            this.phim = phim;
        }

        public Phim getPhim() { return phim; }
        public List<SuatChieu> getSuatChieus() { return suatChieus; }
        public void addSuatChieu(SuatChieu sc) { this.suatChieus.add(sc); }
    }

    /**
     * DTO hỗ trợ thanh chọn ngày chiếu
     */
    public static class DateItem {
        private final String dateValue;
        private final String dayLabel;
        private final String dateDisplay;
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
