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
import java.time.format.DateTimeParseException;
import java.util.LinkedHashSet;
import java.util.Set;

@WebServlet(name = "PhimServlet", value = {
        "/phim/view",
        "/phim/add",
        "/phim/update"
})
public class PhimServlet extends HttpServlet {

    private final PhimRepository phimRepo = new PhimRepository();
    private final TheLoaiRepository theLoaiRepo = new TheLoaiRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        renderView(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String uri = req.getRequestURI();
        if (uri.contains("add")) {
            savePhim(req, resp, false);
        } else if (uri.contains("update")) {
            savePhim(req, resp, true);
        }
    }

    private void renderView(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("listPhim", phimRepo.getAll());
        req.setAttribute("listTheLoai", theLoaiRepo.getAll());
        req.getRequestDispatcher("/phim/view.jsp").forward(req, resp);
    }

    /**
     * Xử lý chung cho cả Thêm mới (isUpdate = false) và Cập nhật (isUpdate = true) phim.
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
        String doTuoi = trimParam(req, "doTuoi");
        String poster = trimParam(req, "poster");
        String trailer = trimParam(req, "trailer");
        String moTa = trimParam(req, "moTa");
        String[] maTheLoais = req.getParameterValues("maTheLoais");

        Phim formPhim = new Phim();
        formPhim.setMaPhim(ma);
        formPhim.setTenPhim(ten);
        formPhim.setDaoDien(daoDien);
        formPhim.setDienVien(dienVien);
        formPhim.setDoTuoi(doTuoi);
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

        String error = null;

        if (ma.isEmpty() || ten.isEmpty() || thoiLuongStr.isEmpty()
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

        if (error == null && !isUpdate && phimRepo.getOne(ma) != null) {
            error = "Mã phim '" + ma + "' đã tồn tại!";
        }

        if (error != null) {
            req.setAttribute("error", error);
            req.setAttribute("openModal", modalMode);
            req.setAttribute("formPhim", formPhim);
            req.setAttribute("formThoiLuong", thoiLuongStr);
            req.setAttribute("formNgayKhoiChieu", ngayKhoiChieuStr);
            req.setAttribute("formNgayKetThuc", ngayKetThucStr);
            renderView(req, resp);
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
            renderView(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/phim/view");
    }

    private String trimParam(HttpServletRequest req, String name) {
        String val = req.getParameter(name);
        return val != null ? val.trim() : "";
    }
}
