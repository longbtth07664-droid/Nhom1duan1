package controller;

import entity.KhuyenMai;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.KhuyenMaiRepository;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "KhuyenMaiServlet", urlPatterns = {"/quan-ly-khuyen-mai"})
public class KhuyenMaiServlet extends HttpServlet {

    private final KhuyenMaiRepository khuyenMaiRepo = new KhuyenMaiRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        String keyword = req.getParameter("keyword");

        List<KhuyenMai> list = khuyenMaiRepo.getAll();
        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = keyword.trim().toLowerCase();
            list = list.stream()
                    .filter(km -> (km.getTenKM() != null && km.getTenKM().toLowerCase().contains(kw))
                            || (km.getMaCode() != null && km.getMaCode().toLowerCase().contains(kw)))
                    .collect(Collectors.toList());
        }

        if ("edit".equalsIgnoreCase(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    KhuyenMai editing = khuyenMaiRepo.getById(Integer.parseInt(idStr.trim()));
                    req.setAttribute("editingKM", editing);
                } catch (Exception ignored) {}
            }
        }

        req.setAttribute("listKhuyenMai", list);
        req.setAttribute("keyword", keyword);
        req.getRequestDispatcher("/khuyen-mai/view.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean ok = khuyenMaiRepo.delete(id);
                req.getSession().setAttribute("kmFlashMsg", ok ? "Đã xóa / hủy mã khuyến mãi!" : "Không thể xóa mã khuyến mãi!");
                req.getSession().setAttribute("kmFlashType", ok ? "success" : "error");
            } catch (Exception e) {
                req.getSession().setAttribute("kmFlashMsg", "ID không hợp lệ!");
                req.getSession().setAttribute("kmFlashType", "error");
            }
            resp.sendRedirect(req.getContextPath() + "/quan-ly-khuyen-mai");
            return;
        }

        if ("toggle".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                KhuyenMai km = khuyenMaiRepo.getById(id);
                if (km != null) {
                    String nextStatus = "Đang áp dụng".equalsIgnoreCase(km.getTrangThai()) ? "Tạm ngưng" : "Đang áp dụng";
                    km.setTrangThai(nextStatus);
                    khuyenMaiRepo.update(km);
                    req.getSession().setAttribute("kmFlashMsg", "Đã chuyển trạng thái mã [" + km.getMaCode() + "] sang: " + nextStatus);
                    req.getSession().setAttribute("kmFlashType", "success");
                }
            } catch (Exception e) {
                req.getSession().setAttribute("kmFlashMsg", "Lỗi khi đổi trạng thái!");
                req.getSession().setAttribute("kmFlashType", "error");
            }
            resp.sendRedirect(req.getContextPath() + "/quan-ly-khuyen-mai");
            return;
        }

        // Lưu (Thêm mới hoặc Cập nhật)
        String maKMStr = req.getParameter("maKM");
        String tenKM = trimOrNull(req.getParameter("tenKM"));
        String maCode = trimOrNull(req.getParameter("maCode"));
        if (tenKM == null || maCode == null) {
            req.getSession().setAttribute("kmFlashMsg", "Vui lòng nhập đầy đủ Tên khuyến mãi và Mã Code!");
            req.getSession().setAttribute("kmFlashType", "error");
            resp.sendRedirect(req.getContextPath() + "/quan-ly-khuyen-mai");
            return;
        }

        KhuyenMai km = new KhuyenMai();
        boolean isEdit = false;
        if (maKMStr != null && !maKMStr.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(maKMStr.trim());
                KhuyenMai existing = khuyenMaiRepo.getById(id);
                if (existing != null) {
                    km = existing;
                    isEdit = true;
                }
            } catch (Exception ignored) {}
        }

        // Kiểm tra trùng MaCode
        KhuyenMai codeOwner = khuyenMaiRepo.getByCode(maCode);
        if (codeOwner != null && (!isEdit || !codeOwner.getMaKM().equals(km.getMaKM()))) {
            req.getSession().setAttribute("kmFlashMsg", "Mã Code [" + maCode.toUpperCase() + "] đã tồn tại! Vui lòng chọn mã khác.");
            req.getSession().setAttribute("kmFlashType", "error");
            resp.sendRedirect(req.getContextPath() + "/quan-ly-khuyen-mai");
            return;
        }

        km.setTenKM(tenKM);
        km.setMaCode(maCode.toUpperCase());
        km.setPhanTramGiam(parseBigDecimal(req.getParameter("phanTramGiam"), BigDecimal.ZERO));
        km.setSoTienGiamToiDa(parseBigDecimal(req.getParameter("soTienGiamToiDa"), BigDecimal.ZERO));
        km.setDonToiThieu(parseBigDecimal(req.getParameter("donToiThieu"), BigDecimal.ZERO));

        km.setGioChieuTu(parseTime(req.getParameter("gioChieuTu")));
        km.setGioChieuDen(parseTime(req.getParameter("gioChieuDen")));

        String[] thuArr = req.getParameterValues("thuTrongTuan");
        if (thuArr == null || thuArr.length == 0 || thuArr.length == 7) {
            km.setThuTrongTuan("ALL");
        } else {
            km.setThuTrongTuan(String.join(",", thuArr));
        }

        km.setTuoiToiThieu(parseIntOrNull(req.getParameter("tuoiToiThieu")));
        km.setTuoiToiDa(parseIntOrNull(req.getParameter("tuoiToiDa")));

        Integer soVe = parseIntOrNull(req.getParameter("soVeToiThieu"));
        km.setSoVeToiThieu(soVe != null && soVe > 0 ? soVe : 1);

        LocalDate bd = parseDate(req.getParameter("ngayBatDau"));
        LocalDate kt = parseDate(req.getParameter("ngayKetThuc"));
        km.setNgayBatDau(bd != null ? bd.atStartOfDay() : LocalDateTime.now());
        km.setNgayKetThuc(kt != null ? kt.atTime(23, 59, 59) : LocalDateTime.now().plusMonths(1));

        String trangThai = trimOrNull(req.getParameter("trangThai"));
        km.setTrangThai(trangThai != null ? trangThai : "Đang áp dụng");

        boolean ok = isEdit ? khuyenMaiRepo.update(km) : khuyenMaiRepo.add(km);
        req.getSession().setAttribute("kmFlashMsg", ok
                ? (isEdit ? "Cập nhật mã khuyến mãi thành công!" : "Thêm mã khuyến mãi mới thành công!")
                : "Lưu mã khuyến mãi thất bại!");
        req.getSession().setAttribute("kmFlashType", ok ? "success" : "error");
        resp.sendRedirect(req.getContextPath() + "/quan-ly-khuyen-mai");
    }

    private String trimOrNull(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        return s.trim();
    }

    private BigDecimal parseBigDecimal(String s, BigDecimal def) {
        if (s == null || s.trim().isEmpty()) return def;
        try {
            return new BigDecimal(s.replaceAll("[^0-9.]", ""));
        } catch (Exception e) {
            return def;
        }
    }

    private Integer parseIntOrNull(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private LocalTime parseTime(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try {
            return LocalTime.parse(s.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private LocalDate parseDate(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try {
            return LocalDate.parse(s.trim());
        } catch (Exception e) {
            return null;
        }
    }
}
