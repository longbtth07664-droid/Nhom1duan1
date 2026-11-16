package controller;

import entity.Ghe;
import entity.LoaiGhe;
import entity.PhongChieu;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.GheRepository;
import repository.LoaiGheRepository;
import repository.PhongChieuRepository;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "GheServlet", urlPatterns = {
        "/ghe",
        "/ghe/view",
        "/ghe/add",
        "/ghe/update",
        "/ghe/delete",
        "/ghe/loai-ghe-add",
        "/ghe/loai-ghe-update",
        "/ghe/loai-ghe-delete"
})
public class GheServlet extends HttpServlet {

    private final GheRepository gheRepo = new GheRepository();
    private final PhongChieuRepository phongChieuRepo = new PhongChieuRepository();
    private final LoaiGheRepository loaiGheRepo = new LoaiGheRepository();

    // Tiếp nhận và hiển thị giao diện sơ đồ ghế trực quan theo phòng chiếu được chọn
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String path = req.getServletPath();
        if (path.equals("/ghe/loai-ghe-delete")) {
            handleDeleteLoaiGhe(req, resp);
            return;
        }

        List<PhongChieu> listPhong = phongChieuRepo.getAll();
        if (listPhong.isEmpty()) {
            req.setAttribute("errorMessage", "Chưa có phòng chiếu nào trong hệ thống! Vui lòng tạo phòng chiếu trước.");
            req.getRequestDispatcher("/ghe/view.jsp").forward(req, resp);
            return;
        }

        // Lấy mã phòng chiếu từ tham số hoặc mặc định chọn phòng đầu tiên
        String maPhong = req.getParameter("maPhong");
        if (maPhong == null || maPhong.trim().isEmpty()) {
            maPhong = listPhong.get(0).getMaPhong();
        } else {
            maPhong = maPhong.trim();
        }

        PhongChieu selectedPhong = phongChieuRepo.getById(maPhong);
        if (selectedPhong == null) {
            selectedPhong = listPhong.get(0);
            maPhong = selectedPhong.getMaPhong();
        }

        // Tải danh sách ghế và nhóm theo từng hàng (A, B, C, D, E...)
        List<Ghe> listGhe = gheRepo.getAllByPhong(maPhong);
        Map<String, List<Ghe>> mapHangGhe = new LinkedHashMap<>();
        int cntThuong = 0;
        int cntVip = 0;
        int cntDoi = 0;
        int cntBaoTri = 0;
        int totalChoNgoi = 0;

        for (Ghe g : listGhe) {
            String hang = g.getHangGhe().toUpperCase();
            mapHangGhe.computeIfAbsent(hang, k -> new ArrayList<>()).add(g);

            // Mỗi ghế đôi (Sweetbox) được tính bằng 2 chỗ ngồi thực tế
            int soCho = g.isGheDoi() ? 2 : 1;
            totalChoNgoi += soCho;

            if ("Bảo trì".equalsIgnoreCase(g.getTrangThai()) || "Hỏng".equalsIgnoreCase(g.getTrangThai())) {
                cntBaoTri++;
            } else if (g.isGheDoi()) {
                cntDoi++;
            } else if (g.getLoaiGhe() != null && g.getLoaiGhe().getMaLoaiGhe() == 2) {
                cntVip++;
            } else {
                cntThuong++;
            }
        }

        req.setAttribute("listPhong", listPhong);
        req.setAttribute("selectedPhong", selectedPhong);
        req.setAttribute("mapHangGhe", mapHangGhe);
        req.setAttribute("listGhe", listGhe);
        req.setAttribute("listLoaiGhe", loaiGheRepo.getAll());
        req.setAttribute("totalGhe", listGhe.size());
        req.setAttribute("totalChoNgoi", totalChoNgoi);
        req.setAttribute("cntThuong", cntThuong);
        req.setAttribute("cntVip", cntVip);
        req.setAttribute("cntDoi", cntDoi);
        req.setAttribute("cntBaoTri", cntBaoTri);
        req.setAttribute("msg", req.getParameter("msg"));
        req.setAttribute("lgMsg", req.getParameter("lgMsg"));
        req.setAttribute("openModal", req.getParameter("openModal"));

        req.getRequestDispatcher("/ghe/view.jsp").forward(req, resp);
    }

    // Tiếp nhận và phân phối các form POST (thêm/sửa/xóa ghế và thêm/sửa loại ghế)
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String path = req.getServletPath();
        if (path.equals("/ghe/add")) {
            handleAdd(req, resp);
        } else if (path.equals("/ghe/update")) {
            handleUpdate(req, resp);
        } else if (path.equals("/ghe/delete")) {
            handleDelete(req, resp);
        } else if (path.equals("/ghe/loai-ghe-add")) {
            handleAddLoaiGhe(req, resp);
        } else if (path.equals("/ghe/loai-ghe-update")) {
            handleUpdateLoaiGhe(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/ghe");
        }
    }

    // ==================== QUẢN LÝ GHẾ ====================

    // Kiểm tra dữ liệu đầu vào và thêm một ghế lẻ vào phòng chiếu
    private void handleAdd(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String maPhong = trimParam(req, "maPhong");
        String hangGhe = trimParam(req, "hangGhe").toUpperCase();
        String soGheStr = trimParam(req, "soGhe");
        String maLoaiStr = trimParam(req, "maLoaiGhe");
        String giaStr = trimParam(req, "gia");
        String trangThai = trimParam(req, "trangThai");

        if (maPhong.isEmpty() || hangGhe.isEmpty() || soGheStr.isEmpty() || maLoaiStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=empty");
            return;
        }

        try {
            int soGhe = Integer.parseInt(soGheStr);
            int maLoai = Integer.parseInt(maLoaiStr);
            if (soGhe <= 0) {
                resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=invalid_seat");
                return;
            }

            if (gheRepo.existsSeat(maPhong, hangGhe, soGhe, null)) {
                resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=duplicate_seat");
                return;
            }

            BigDecimal gia = BigDecimal.valueOf(80000);
            if (!giaStr.isEmpty()) {
                gia = new BigDecimal(giaStr.replace(".", "").replace(",", "").trim());
            }

            PhongChieu pc = phongChieuRepo.getById(maPhong);
            LoaiGhe lg = loaiGheRepo.getOne(maLoai);
            if (pc == null || lg == null) {
                resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=error");
                return;
            }

            // Tính toán tổng số chỗ ngồi hiện có của phòng chiếu (Ghế đôi = 2 chỗ, Ghế đơn = 1 chỗ)
            List<Ghe> currentSeats = gheRepo.getAllByPhong(maPhong);
            int currentCapacity = 0;
            for (Ghe s : currentSeats) {
                currentCapacity += s.isGheDoi() ? 2 : 1;
            }

            // Xác định số chỗ ngồi của chiếc ghế chuẩn bị thêm
            boolean isDoi = (lg.getMaLoaiGhe() != null && lg.getMaLoaiGhe() == 3)
                    || (lg.getTenLoaiGhe() != null && (lg.getTenLoaiGhe().toLowerCase().contains("đôi") || lg.getTenLoaiGhe().toLowerCase().contains("sweetbox")));
            int newCho = isDoi ? 2 : 1;

            // Chặn thêm ghế nếu tổng số chỗ vượt quá sức chứa tối đa của phòng chiếu
            int sucChuaToiDa = pc.getSucChua() != null ? pc.getSucChua() : 0;
            if (currentCapacity + newCho > sucChuaToiDa) {
                resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=full_capacity");
                return;
            }

            Ghe ghe = new Ghe();
            ghe.setPhongChieu(pc);
            ghe.setLoaiGhe(lg);
            ghe.setHangGhe(hangGhe);
            ghe.setSoGhe(soGhe);
            ghe.setTrangThai(trangThai.isEmpty() ? "Hoạt động" : trangThai);
            ghe.setGia(gia);

            boolean ok = gheRepo.add(ghe);
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=" + (ok ? "add_ok" : "error"));
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=error");
        }
    }

    // Kiểm tra và cập nhật thông tin loại ghế, trạng thái hoặc giá của ghế
    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String maGheStr = trimParam(req, "maGhe");
        String maPhong = trimParam(req, "maPhong");
        String hangGhe = trimParam(req, "hangGhe").toUpperCase();
        String soGheStr = trimParam(req, "soGhe");
        String maLoaiStr = trimParam(req, "maLoaiGhe");
        String giaStr = trimParam(req, "gia");
        String trangThai = trimParam(req, "trangThai");

        try {
            int maGhe = Integer.parseInt(maGheStr);
            int soGhe = Integer.parseInt(soGheStr);
            int maLoai = Integer.parseInt(maLoaiStr);

            Ghe ghe = gheRepo.getOne(maGhe);
            if (ghe == null) {
                resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=not_found");
                return;
            }

            if (gheRepo.existsSeat(maPhong, hangGhe, soGhe, maGhe)) {
                resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=duplicate_seat");
                return;
            }

            BigDecimal gia = ghe.getGia();
            if (!giaStr.isEmpty()) {
                gia = new BigDecimal(giaStr.replace(".", "").replace(",", "").trim());
            }

            LoaiGhe lg = loaiGheRepo.getOne(maLoai);
            if (lg == null) {
                resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=error");
                return;
            }

            // Kiểm tra ràng buộc sức chứa nếu cập nhật từ ghế đơn sang ghế đôi
            PhongChieu pc = ghe.getPhongChieu();
            int sucChuaToiDa = (pc != null && pc.getSucChua() != null) ? pc.getSucChua() : 0;
            boolean oldIsDoi = ghe.isGheDoi();
            boolean newIsDoi = (lg.getMaLoaiGhe() != null && lg.getMaLoaiGhe() == 3)
                    || (lg.getTenLoaiGhe() != null && (lg.getTenLoaiGhe().toLowerCase().contains("đôi") || lg.getTenLoaiGhe().toLowerCase().contains("sweetbox")));
            int oldCho = oldIsDoi ? 2 : 1;
            int newCho = newIsDoi ? 2 : 1;

            if (newCho > oldCho) {
                List<Ghe> currentSeats = gheRepo.getAllByPhong(maPhong);
                int currentCapacity = 0;
                for (Ghe s : currentSeats) {
                    currentCapacity += s.isGheDoi() ? 2 : 1;
                }
                if (currentCapacity - oldCho + newCho > sucChuaToiDa) {
                    resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=exceed_capacity");
                    return;
                }
            }

            ghe.setLoaiGhe(lg);
            ghe.setHangGhe(hangGhe);
            ghe.setSoGhe(soGhe);
            ghe.setTrangThai(trangThai.isEmpty() ? "Hoạt động" : trangThai);
            ghe.setGia(gia);

            boolean ok = gheRepo.update(ghe);
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=" + (ok ? "update_ok" : "error"));
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=error");
        }
    }

    // Xóa một ghế ra khỏi phòng chiếu sau khi kiểm tra không có vé nào ràng buộc
    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String maGheStr = trimParam(req, "maGhe");
        String maPhong = trimParam(req, "maPhong");

        try {
            int maGhe = Integer.parseInt(maGheStr);

            if (gheRepo.isGheBooked(maGhe)) {
                resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=in_use");
                return;
            }

            boolean ok = gheRepo.delete(maGhe);
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=" + (ok ? "delete_ok" : "error"));
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&msg=error");
        }
    }

    // ==================== QUẢN LÝ LOẠI GHẾ (CRUD LOẠI GHẾ) ====================

    // Kiểm tra dữ liệu và thêm mới một loại ghế vào cơ sở dữ liệu
    private void handleAddLoaiGhe(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String maPhong = trimParam(req, "maPhong");
        String tenLoaiGhe = trimParam(req, "tenLoaiGhe");
        String phuThuStr = trimParam(req, "phuThu");

        if (tenLoaiGhe.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&openModal=loaiGhe&lgMsg=empty");
            return;
        }

        if (loaiGheRepo.existsByTen(tenLoaiGhe, null)) {
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&openModal=loaiGhe&lgMsg=duplicate");
            return;
        }

        BigDecimal phuThu = BigDecimal.ZERO;
        if (!phuThuStr.isEmpty()) {
            try {
                phuThu = new BigDecimal(phuThuStr.replace(".", "").replace(",", "").trim());
            } catch (Exception ignored) {}
        }

        LoaiGhe lg = new LoaiGhe();
        lg.setTenLoaiGhe(tenLoaiGhe);
        lg.setPhuThu(phuThu);

        boolean ok = loaiGheRepo.add(lg);
        resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&openModal=loaiGhe&lgMsg=" + (ok ? "add_ok" : "error"));
    }

    // Kiểm tra dữ liệu và cập nhật tên hoặc phụ thu của loại ghế
    private void handleUpdateLoaiGhe(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String maPhong = trimParam(req, "maPhong");
        String maLoaiStr = trimParam(req, "maLoaiGhe");
        String tenLoaiGhe = trimParam(req, "tenLoaiGhe");
        String phuThuStr = trimParam(req, "phuThu");

        if (maLoaiStr.isEmpty() || tenLoaiGhe.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&openModal=loaiGhe&lgMsg=empty");
            return;
        }

        try {
            int maLoai = Integer.parseInt(maLoaiStr);
            if (loaiGheRepo.existsByTen(tenLoaiGhe, maLoai)) {
                resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&openModal=loaiGhe&lgMsg=duplicate");
                return;
            }

            LoaiGhe lg = loaiGheRepo.getOne(maLoai);
            if (lg == null) {
                resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&openModal=loaiGhe&lgMsg=not_found");
                return;
            }

            BigDecimal phuThu = BigDecimal.ZERO;
            if (!phuThuStr.isEmpty()) {
                phuThu = new BigDecimal(phuThuStr.replace(".", "").replace(",", "").trim());
            }

            lg.setTenLoaiGhe(tenLoaiGhe);
            lg.setPhuThu(phuThu);

            boolean ok = loaiGheRepo.update(lg);
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&openModal=loaiGhe&lgMsg=" + (ok ? "update_ok" : "error"));
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&openModal=loaiGhe&lgMsg=error");
        }
    }

    // Xóa một loại ghế sau khi kiểm tra không có ghế nào trong rạp đang sử dụng
    private void handleDeleteLoaiGhe(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String maPhong = trimParam(req, "maPhong");
        String idStr = trimParam(req, "id");

        if (idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&openModal=loaiGhe&lgMsg=error");
            return;
        }

        try {
            int maLoai = Integer.parseInt(idStr);
            if (loaiGheRepo.isLoaiGheUsed(maLoai)) {
                resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&openModal=loaiGhe&lgMsg=in_use");
                return;
            }

            boolean ok = loaiGheRepo.delete(maLoai);
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&openModal=loaiGhe&lgMsg=" + (ok ? "delete_ok" : "error"));
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/ghe?maPhong=" + maPhong + "&openModal=loaiGhe&lgMsg=error");
        }
    }

    // Đọc tham số từ request và cắt bỏ khoảng trắng thừa hai đầu
    private String trimParam(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null ? v.trim() : "";
    }
}
