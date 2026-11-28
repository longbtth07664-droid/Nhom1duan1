package controller;

import entity.Phim;
import entity.PhongChieu;
import entity.SuatChieu;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.PhimRepository;
import repository.PhongChieuRepository;
import repository.SuatChieuRepository;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet(name = "SuatChieuServlet", value = {
        "/suat-chieu",
        "/suat-chieu/",
        "/suat-chieu/view",
        "/suat-chieu/detail",
        "/suat-chieu/view-update",
        "/suat-chieu/add",
        "/suat-chieu/update",
        "/suat-chieu/cancel"
})
public class SuatChieuServlet extends HttpServlet {

    private final SuatChieuRepository suatChieuRepo = new SuatChieuRepository();
    private final PhimRepository phimRepo = new PhimRepository();
    private final PhongChieuRepository phongChieuRepo = new PhongChieuRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();
        if (uri.contains("cancel")) {
            String idStr = req.getParameter("id");
            String lyDo = req.getParameter("lyDo");
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr.trim());
                    suatChieuRepo.cancel(id, lyDo);
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/suat-chieu/view");
            return;
        }

        if (uri.contains("view-update")) {
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr.trim());
                    SuatChieu sc = suatChieuRepo.getOne(id);
                    if (sc != null) {
                        req.setAttribute("scUpdate", sc);
                        req.setAttribute("openModal", "update");
                    }
                } catch (NumberFormatException ignored) {}
            }
            renderView(req, resp);
            return;
        }

        if (uri.contains("detail")) {
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr.trim());
                    SuatChieu sc = suatChieuRepo.getOne(id);
                    if (sc != null) {
                        req.setAttribute("scDetail", sc);
                        req.setAttribute("openModal", "detail");
                    }
                } catch (NumberFormatException ignored) {}
            }
            renderView(req, resp);
            return;
        }

        renderView(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String uri = req.getRequestURI();
        if (uri.contains("add")) {
            saveSuatChieu(req, resp, false);
        } else if (uri.contains("update")) {
            saveSuatChieu(req, resp, true);
        } else if (uri.contains("cancel")) {
            String idStr = req.getParameter("id");
            String lyDo = req.getParameter("lyDo");
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr.trim());
                    suatChieuRepo.cancel(id, lyDo);
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/suat-chieu/view");
        }
    }

    private void renderView(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String maPhim = trimParam(req, "maPhim");
        String maPhong = trimParam(req, "maPhong");
        String dinhDang = trimParam(req, "dinhDang");
        String trangThai = trimParam(req, "trangThai");
        String tuNgayStr = trimParam(req, "tuNgay");
        String denNgayStr = trimParam(req, "denNgay");
        String keyword = trimParam(req, "keyword");

        LocalDate tuNgay = null;
        LocalDate denNgay = null;
        try {
            if (!tuNgayStr.isEmpty()) tuNgay = LocalDate.parse(tuNgayStr);
            if (!denNgayStr.isEmpty()) denNgay = LocalDate.parse(denNgayStr);
        } catch (DateTimeParseException ignored) {}

        List<SuatChieu> list;
        boolean hasFilter = !maPhim.isEmpty() || !maPhong.isEmpty() || !dinhDang.isEmpty()
                || !trangThai.isEmpty() || tuNgay != null || denNgay != null || !keyword.isEmpty();

        if (hasFilter) {
            list = suatChieuRepo.filter(maPhim, maPhong, dinhDang, trangThai, tuNgay, denNgay, keyword);
        } else {
            list = suatChieuRepo.getAll();
        }

        // Phân trang (Pagination) - Mặc định 10 suất chiếu / 1 trang
        int pageSize = 10;
        String pageSizeParam = trimParam(req, "pageSize");
        if (!pageSizeParam.isEmpty()) {
            try {
                int ps = Integer.parseInt(pageSizeParam);
                if (ps > 0 && ps <= 100) {
                    pageSize = ps;
                }
            } catch (NumberFormatException ignored) {}
        }

        int totalItems = list.size();
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages <= 0) totalPages = 1;

        int currentPage = 1;
        String pageParam = trimParam(req, "page");
        if (!pageParam.isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {}
        }
        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        int fromIndex = (currentPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalItems);

        List<SuatChieu> pagedList = (totalItems > 0 && fromIndex < totalItems)
                ? list.subList(fromIndex, toIndex)
                : java.util.Collections.emptyList();

        // Tính toán 5 chỉ số thống kê cards
        int total = 0;
        int active = 0;
        int upcoming = 0;
        int cancelled = 0;

        List<SuatChieu> allList = suatChieuRepo.getAll();
        for (SuatChieu sc : allList) {
            total++;
            String st = sc.getTrangThai();
            if ("Đang mở bán".equalsIgnoreCase(st)) {
                active++;
            } else if ("Sắp diễn ra".equalsIgnoreCase(st)) {
                upcoming++;
            } else if ("Đã hủy".equalsIgnoreCase(st)) {
                cancelled++;
            }
        }

        req.setAttribute("listSuatChieu", pagedList);
        req.setAttribute("allSuatChieu", list);
        req.setAttribute("currentPage", currentPage);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalItems", totalItems);
        req.setAttribute("fromIndex", totalItems > 0 ? (fromIndex + 1) : 0);
        req.setAttribute("toIndex", toIndex);
        List<Phim> allPhim = phimRepo.getAll();
        List<Phim> listPhimDangChieu = new java.util.ArrayList<>();
        for (Phim p : allPhim) {
            if (p.getTrangThai() != null && "Đang chiếu".equalsIgnoreCase(p.getTrangThai().trim())) {
                listPhimDangChieu.add(p);
            }
        }

        req.setAttribute("listPhim", allPhim);
        req.setAttribute("listPhimDangChieu", listPhimDangChieu);
        req.setAttribute("listPhong", phongChieuRepo.getAll());

        req.setAttribute("statTotal", total);
        req.setAttribute("statActive", active);
        req.setAttribute("statUpcoming", upcoming);
        req.setAttribute("statCancelled", cancelled);
        req.setAttribute("statRate", "85%");

        req.setAttribute("filterMaPhim", maPhim);
        req.setAttribute("filterMaPhong", maPhong);
        req.setAttribute("filterDinhDang", dinhDang);
        req.setAttribute("filterTrangThai", trangThai);
        req.setAttribute("filterTuNgay", tuNgayStr);
        req.setAttribute("filterDenNgay", denNgayStr);
        req.setAttribute("filterKeyword", keyword);

        req.getRequestDispatcher("/suat-chieu/view.jsp").forward(req, resp);
    }

    private void saveSuatChieu(HttpServletRequest req, HttpServletResponse resp, boolean isUpdate)
            throws ServletException, IOException {
        String idStr = trimParam(req, "maSuat");
        String maPhim = trimParam(req, "maPhim");
        String maPhong = trimParam(req, "maPhong");
        String dinhDang = trimParam(req, "dinhDang");
        String ngayChieuStr = trimParam(req, "ngayChieu");
        String gioBatDauStr = trimParam(req, "gioBatDau");
        String giaVeStr = trimParam(req, "giaVeCoBan");
        String trangThai = trimParam(req, "trangThai");
        String thoiGianDonDepStr = trimParam(req, "thoiGianDonDep");
        int thoiGianDonDep = 15;
        if (!thoiGianDonDepStr.isEmpty()) {
            try {
                int dd = Integer.parseInt(thoiGianDonDepStr);
                if (dd >= 0 && dd <= 120) {
                    thoiGianDonDep = dd;
                }
            } catch (NumberFormatException ignored) {}
        }

        if (dinhDang.isEmpty()) dinhDang = "2D";
        if (trangThai.isEmpty()) trangThai = "Đang mở bán";

        String error = null;
        if (maPhim.isEmpty() || maPhong.isEmpty() || ngayChieuStr.isEmpty() || gioBatDauStr.isEmpty()) {
            error = "Vui lòng nhập đầy đủ các trường thông tin bắt buộc (*)!";
        }

        Integer maSuat = null;
        if (isUpdate) {
            try {
                maSuat = Integer.parseInt(idStr);
            } catch (NumberFormatException e) {
                error = "Mã suất chiếu không hợp lệ!";
            }
        }

        LocalDate ngayChieu = null;
        LocalTime gioBatDau = null;
        LocalTime gioKetThuc = null;

        if (error == null) {
            try {
                ngayChieu = LocalDate.parse(ngayChieuStr);
            } catch (DateTimeParseException e) {
                error = "Định dạng ngày chiếu không hợp lệ (yyyy-MM-dd)!";
            }
        }

        if (error == null) {
            try {
                if (gioBatDauStr.length() == 5) {
                    gioBatDauStr += ":00";
                }
                gioBatDau = LocalTime.parse(gioBatDauStr);
            } catch (DateTimeParseException e) {
                error = "Định dạng giờ bắt đầu không hợp lệ (HH:mm)!";
            }
        }

        BigDecimal giaVeCoBan = BigDecimal.valueOf(80000);
        if (error == null && !giaVeStr.isEmpty()) {
            try {
                giaVeCoBan = new BigDecimal(giaVeStr.replace(".", "").replace(",", "").trim());
            } catch (Exception e) {
                giaVeCoBan = BigDecimal.valueOf(80000);
            }
        }

        Phim phim = null;
        PhongChieu phong = null;

        if (error == null) {
            phim = phimRepo.getOne(maPhim);
            phong = phongChieuRepo.getById(maPhong);

            if (phim == null) {
                error = "Phim đã chọn không tồn tại!";
            } else if (phong == null) {
                error = "Phòng chiếu đã chọn không tồn tại!";
            } else {
                String ttPhim = phim.getTrangThai() != null ? phim.getTrangThai().trim() : "";
                if (!"Đang chiếu".equalsIgnoreCase(ttPhim)) {
                    error = "Không thể xếp suất chiếu cho phim '" + phim.getTenPhim()
                            + "' vì phim đang ở trạng thái [" + (ttPhim.isEmpty() ? "Không xác định" : ttPhim)
                            + "]. Chỉ được chọn phim Đang chiếu!";
                }
            }
        }

        if (error == null && phim != null && gioBatDau != null) {
            int tongPhut = phim.getThoiLuong() + thoiGianDonDep;
            gioKetThuc = gioBatDau.plusMinutes(tongPhut);
        }

        if (error == null) {
            boolean trungLich = suatChieuRepo.checkTrungLich(maPhong, ngayChieu, gioBatDau, gioKetThuc, maSuat);
            if (trungLich) {
                error = "Phòng '" + phong.getTenPhong() + "' đã có suất chiếu khác trong khung giờ "
                        + gioBatDau + " - " + gioKetThuc + " ngày " + ngayChieu + "!";
            }
        }

        if (error != null) {
            SuatChieu formSc = new SuatChieu();
            formSc.setMaSuat(maSuat);
            formSc.setPhim(phim);
            formSc.setPhongChieu(phong);
            formSc.setDinhDang(dinhDang);
            formSc.setNgayChieu(ngayChieu);
            formSc.setGioBatDau(gioBatDau);
            formSc.setGioKetThuc(gioKetThuc);
            formSc.setGiaVeCoBan(giaVeCoBan);
            formSc.setTrangThai(trangThai);

            req.setAttribute("errorMessage", error);
            req.setAttribute("formSc", formSc);
            req.setAttribute("rawMaPhim", maPhim);
            req.setAttribute("rawMaPhong", maPhong);
            req.setAttribute("rawNgayChieu", ngayChieuStr);
            req.setAttribute("rawGioBatDau", gioBatDauStr);
            req.setAttribute("rawThoiGianDonDep", thoiGianDonDep);
            req.setAttribute("openModal", isUpdate ? "update" : "add");
            renderView(req, resp);
            return;
        }

        SuatChieu sc = isUpdate ? suatChieuRepo.getOne(maSuat) : new SuatChieu();
        if (sc == null) sc = new SuatChieu();

        sc.setPhim(phim);
        sc.setPhongChieu(phong);
        sc.setDinhDang(dinhDang);
        sc.setNgayChieu(ngayChieu);
        sc.setGioBatDau(gioBatDau);
        sc.setGioKetThuc(gioKetThuc);
        sc.setGiaVeCoBan(giaVeCoBan);
        sc.setTrangThai(trangThai);

        if (isUpdate) {
            suatChieuRepo.update(sc);
        } else {
            suatChieuRepo.add(sc);
        }

        resp.sendRedirect(req.getContextPath() + "/suat-chieu/view");
    }

    private String trimParam(HttpServletRequest req, String name) {
        String val = req.getParameter(name);
        return val == null ? "" : val.trim();
    }
}
