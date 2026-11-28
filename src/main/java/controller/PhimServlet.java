package controller;

import entity.DinhDang;
import entity.Phim;
import entity.TheLoai;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.DinhDangRepository;
import repository.PhimRepository;
import repository.TheLoaiRepository;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@WebServlet(name = "PhimServlet", value = {
        "/phim/view",
        "/phim/add",
        "/phim/update"
})
public class PhimServlet extends HttpServlet {

    private final PhimRepository phimRepo = new PhimRepository();
    private final TheLoaiRepository theLoaiRepo = new TheLoaiRepository();
    private final DinhDangRepository dinhDangRepo = new DinhDangRepository();

    // [PHÂN TRANG - BACKEND] Số lượng phim hiển thị trên 1 trang (8 phim/trang)
    private static final int PAGE_SIZE = 8;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("search".equals(action)) {
            timKiemPhim(req, resp);
        } else {
            hienThiDanhSach(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String uri = req.getRequestURI();
        if (uri.contains("add")) {
            themPhim(req, resp);
        } else if (uri.contains("update")) {
            capNhatPhim(req, resp);
        }
    }

    // =========================================================================
    // [PHÂN TRANG - BACKEND] Hàm xử lý tính toán số trang và phân trang danh sách phim
    // =========================================================================
    private void hienThiVaPhanTrang(HttpServletRequest req, HttpServletResponse resp, String keyword, String maTheLoai, String trangThai)
            throws ServletException, IOException {
        // 1. Nhận số trang hiện tại từ URL (?page=...). Mặc định là trang 1
        int page = 1;
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        // 2. Đếm tổng số phim phù hợp với từ khóa, thể loại và trạng thái đã chọn
        int totalItems = phimRepo.countSearch(keyword, maTheLoai, trangThai);

        // 3. Tính tổng số trang (totalPages = làm tròn lên của totalItems / PAGE_SIZE)
        int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);
        if (totalPages <= 0) totalPages = 1;

        // Giới hạn số trang hợp lệ từ 1 đến totalPages
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        // 4. Lấy danh sách phim của đúng trang hiện tại (tối đa 8 phim)
        List<Phim> pagedList = phimRepo.searchPaged(keyword, maTheLoai, trangThai, page, PAGE_SIZE);

        // 5. Gửi dữ liệu phân trang và bộ lọc sang JSP
        req.setAttribute("listPhim", pagedList);
        req.setAttribute("listTheLoai", theLoaiRepo.getAll());
        req.setAttribute("listDinhDang", dinhDangRepo.getAll());
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalItems", totalItems);
        req.setAttribute("keyword", keyword != null ? keyword.trim() : "");
        req.setAttribute("selectedTheLoai", (maTheLoai != null && !"Tất cả".equalsIgnoreCase(maTheLoai.trim())) ? maTheLoai.trim() : "");
        req.setAttribute("selectedTrangThai", trangThai != null ? trangThai.trim() : "");

        req.getRequestDispatcher("/phim/view.jsp").forward(req, resp);
    }

    // 1. Hiển thị danh sách phim mặc định
    private void hienThiDanhSach(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String maTheLoai = req.getParameter("maTheLoai");
        String trangThai = req.getParameter("trangThai");
        hienThiVaPhanTrang(req, resp, keyword, maTheLoai, trangThai);
    }

    // 2. Tìm kiếm và lọc phim
    private void timKiemPhim(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String maTheLoai = req.getParameter("maTheLoai");
        String trangThai = req.getParameter("trangThai");
        hienThiVaPhanTrang(req, resp, keyword, maTheLoai, trangThai);
    }

    // 3. Xử lý thêm mới phim
    private void themPhim(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        savePhim(req, resp, false);
    }

    // 4. Xử lý cập nhật phim
    private void capNhatPhim(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        savePhim(req, resp, true);
    }

    /**
     * Hàm dùng chung để validate và lưu dữ liệu phim (cho cả Thêm mới và Cập nhật)
     */
    private void savePhim(HttpServletRequest req, HttpServletResponse resp, boolean isUpdate)
            throws ServletException, IOException {
        String modalMode = isUpdate ? "update" : "add";

        String ma = trimParam(req, "maPhim");
        String ten = trimParam(req, "tenPhim");
        String thoiLuongStr = trimParam(req, "thoiLuong");
        String ngayKhoiChieuStr = trimParam(req, "ngayKhoiChieu");
        String ngayKetThucStr = trimParam(req, "ngayKetThuc");
        String daoDien = trimParam(req, "daoDien");
        String dienVien = trimParam(req, "dienVien");
        String quocGia = trimParam(req, "quocGia");
        String doTuoi = trimParam(req, "doTuoi");
        String trangThai = trimParam(req, "trangThai");
        String poster = trimParam(req, "poster");
        String trailer = trimParam(req, "trailer");
        String moTa = trimParam(req, "moTa");
        String[] maTheLoais = req.getParameterValues("maTheLoais");
        String[] maDinhDangs = req.getParameterValues("maDinhDangs");

        Phim formPhim = new Phim();
        if (isUpdate && !ma.isEmpty()) {
            try {
                formPhim.setMaPhim(Integer.parseInt(ma));
            } catch (NumberFormatException ignored) {}
        }
        formPhim.setTenPhim(ten);
        formPhim.setDaoDien(daoDien);
        formPhim.setDienVien(dienVien);
        formPhim.setQuocGia(quocGia);
        formPhim.setDoTuoi(doTuoi);
        formPhim.setTrangThai(trangThai.isEmpty() ? "Đang chiếu" : trangThai);
        formPhim.setPoster(poster);
        formPhim.setTrailer(trailer);
        formPhim.setMoTa(moTa);

        Set<TheLoai> selectedTheLoais = new LinkedHashSet<>();
        if (maTheLoais != null) {
            for (String maTl : maTheLoais) {
                if (maTl != null && !maTl.trim().isEmpty()) {
                    TheLoai tl = theLoaiRepo.getOne(maTl.trim());
                    if (tl != null) {
                        selectedTheLoais.add(tl);
                    }
                }
            }
        }
        formPhim.setTheLoais(selectedTheLoais);

        Set<DinhDang> selectedDinhDangs = new LinkedHashSet<>();
        if (maDinhDangs != null) {
            for (String maDd : maDinhDangs) {
                if (maDd != null && !maDd.trim().isEmpty()) {
                    DinhDang dd = dinhDangRepo.getOne(maDd.trim());
                    if (dd != null) {
                        selectedDinhDangs.add(dd);
                    }
                }
            }
        }
        formPhim.setDinhDangs(selectedDinhDangs);

        String error = null;

        if ((isUpdate && ma.isEmpty()) || ten.isEmpty() || thoiLuongStr.isEmpty()
                || ngayKhoiChieuStr.isEmpty() || ngayKetThucStr.isEmpty()) {
            error = "Vui lòng nhập đầy đủ các trường bắt buộc (*)!";
        }

        Integer thoiLuong = null;
        if (error == null) {
            try {
                thoiLuong = Integer.parseInt(thoiLuongStr);
                if (thoiLuong <= 0) {
                    error = "Thời lượng phim phải lớn hơn 0 phút!";
                }
            } catch (NumberFormatException e) {
                error = "Thời lượng phim phải là số nguyên hợp lệ!";
            }
        }
        formPhim.setThoiLuong(thoiLuong);

        LocalDate ngayKhoiChieu = null;
        LocalDate ngayKetThuc = null;
        if (error == null) {
            try {
                ngayKhoiChieu = LocalDate.parse(ngayKhoiChieuStr);
                ngayKetThuc = LocalDate.parse(ngayKetThucStr);
                if (ngayKetThuc.isBefore(ngayKhoiChieu)) {
                    error = "Ngày kết thúc không được nhỏ hơn ngày khởi chiếu!";
                }
            } catch (DateTimeParseException e) {
                error = "Định dạng ngày khởi chiếu / kết thúc không hợp lệ!";
            }

        }

        formPhim.setNgayKhoiChieu(ngayKhoiChieu);
        formPhim.setNgayKetThuc(ngayKetThuc);
        // Tự động tính trạng thái theo ngày khởi chiếu và kết thúc
        LocalDate homNay = LocalDate.now();
        String trangThaiTuDong;

        if (ngayKhoiChieu != null && homNay.isBefore(ngayKhoiChieu)) {
            trangThaiTuDong = "Sắp chiếu";
        } else if (ngayKetThuc != null && homNay.isAfter(ngayKetThuc)) {
            trangThaiTuDong = "Ngừng chiếu";
        } else {
            trangThaiTuDong = "Đang chiếu";
        }

        formPhim.setTrangThai(trangThaiTuDong);
        if (error != null) {
            req.setAttribute("error", error);
            req.setAttribute("openModal", modalMode);
            req.setAttribute("formPhim", formPhim);
            req.setAttribute("formThoiLuong", thoiLuongStr);
            req.setAttribute("formNgayKhoiChieu", ngayKhoiChieuStr);
            req.setAttribute("formNgayKetThuc", ngayKetThucStr);
            hienThiDanhSach(req, resp);
            return;
        }

        boolean ok = isUpdate ? phimRepo.update(formPhim) : phimRepo.add(formPhim);
        if (!ok) {
            req.setAttribute("error", "Không thể lưu dữ liệu phim xuống hệ thống!");
            req.setAttribute("openModal", modalMode);
            req.setAttribute("formPhim", formPhim);
            req.setAttribute("formThoiLuong", thoiLuongStr);
            req.setAttribute("formNgayKhoiChieu", ngayKhoiChieuStr);
            req.setAttribute("formNgayKetThuc", ngayKetThucStr);
            hienThiDanhSach(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/phim/view");
    }

    private String trimParam(HttpServletRequest req, String name) {
        String val = req.getParameter(name);
        return val != null ? val.trim() : "";
    }
}
