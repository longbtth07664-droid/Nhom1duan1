package controller;

import entity.DinhDang;
import entity.LoaiPhong;
import entity.PhongChieu;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.DinhDangRepository;
import repository.LoaiPhongRepository;
import repository.PhongChieuRepository;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "PhongChieuServlet", urlPatterns = {
        "/phong-chieu/view",
        "/phong-chieu/detail",
        "/phong-chieu/view-update",
        "/phong-chieu/add",
        "/phong-chieu/update",
        "/phong-chieu/loai-phong-add",
        "/phong-chieu/loai-phong-update",
        "/phong-chieu/loai-phong-delete"
})
public class PhongChieuServlet extends HttpServlet {

    private final PhongChieuRepository repo = new PhongChieuRepository();
    private final LoaiPhongRepository loaiPhongRepo = new LoaiPhongRepository();
    private final DinhDangRepository dinhDangRepo = new DinhDangRepository();

    private static final String VIEW = "/Phong-Chieu/view.jsp";
    private static final String VIEW_UPDATE = "/Phong-Chieu/view-update.jsp";

    // Điều hướng GET: xem danh sách, xem chi tiết, mở form sửa, hoặc xóa loại phòng.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if (path.equals("/phong-chieu/loai-phong-delete")) {
            handleDeleteLoaiPhong(request, response);
            return;
        }

        if (path.equals("/phong-chieu/view")) {
            // Hiển thị danh sách phòng chiếu có phân trang (5 phòng / trang).
            loadDataPaging(request);
            request.getRequestDispatcher(VIEW).forward(request, response);

        } else if (path.equals("/phong-chieu/detail")) {
            // Tải chi tiết một phòng và mở modal xem chi tiết.
            String maPhong = getParameter(request, "id");
            PhongChieu pc = repo.getById(maPhong);

            if (pc == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phòng chiếu!");
                return;
            }

            request.setAttribute("pc", pc);
            request.setAttribute("openModal", "detail");
            loadDataPaging(request);
            request.getRequestDispatcher(VIEW).forward(request, response);

        } else if (path.equals("/phong-chieu/view-update")) {
            // Tải dữ liệu phòng và chuyển sang form sửa.
            String maPhong = getParameter(request, "id");
            PhongChieu pc = repo.getById(maPhong);

            if (pc == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phòng chiếu cần cập nhật!");
                return;
            }

            request.setAttribute("pc", pc);
            List<DinhDang> phongDD = dinhDangRepo.getByPhong(pc.getMaPhong());
            List<Integer> selectedDDIds = new ArrayList<>();
            for (DinhDang d : phongDD) selectedDDIds.add(d.getMaDinhDang());
            request.setAttribute("selectedDinhDangIds", selectedDDIds);
            loadDataPaging(request);
            request.getRequestDispatcher(VIEW_UPDATE).forward(request, response);

        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // Phân phối POST tới hàm xử lý tương ứng (thêm/sửa phòng, thêm/sửa loại phòng).
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        if (path.equals("/phong-chieu/add")) {
            handleAdd(request, response);
        } else if (path.equals("/phong-chieu/update")) {
            handleUpdate(request, response);
        } else if (path.equals("/phong-chieu/loai-phong-add")) {
            handleAddLoaiPhong(request, response);
        } else if (path.equals("/phong-chieu/loai-phong-update")) {
            handleUpdateLoaiPhong(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ==================== QUẢN LÝ LOẠI PHÒNG ====================

    // Kiểm tra loại phòng không còn được dùng bởi phòng nào, rồi xóa.
    private void handleDeleteLoaiPhong(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = getParameter(request, "id");
        if (id.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/phong-chieu/view?openModal=loaiPhong&lpMsg=error");
            return;
        }

        if (loaiPhongRepo.isLoaiPhongUsed(id)) {
            response.sendRedirect(request.getContextPath() + "/phong-chieu/view?openModal=loaiPhong&lpMsg=in_use");
            return;
        }

        boolean ok = loaiPhongRepo.delete(id);
        response.sendRedirect(request.getContextPath() + "/phong-chieu/view?openModal=loaiPhong&lpMsg=" + (ok ? "delete_ok" : "error"));
    }

    // Validate mã và tên, kiểm tra trùng mã, rồi thêm mới loại phòng chiếu.
    private void handleAddLoaiPhong(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ma = getParameter(request, "maLoaiPhong");
        String ten = getParameter(request, "tenLoaiPhong");

        if (ma.isEmpty() || ten.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/phong-chieu/view?openModal=loaiPhong&lpMsg=empty");
            return;
        }

        if (loaiPhongRepo.getOne(ma) != null) {
            response.sendRedirect(request.getContextPath() + "/phong-chieu/view?openModal=loaiPhong&lpMsg=duplicate");
            return;
        }

        boolean ok = loaiPhongRepo.add(new LoaiPhong(ma, ten));
        response.sendRedirect(request.getContextPath() + "/phong-chieu/view?openModal=loaiPhong&lpMsg=" + (ok ? "add_ok" : "error"));
    }

    // Validate mã và tên, rồi lưu thay đổi tên loại phòng chiếu.
    private void handleUpdateLoaiPhong(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ma = getParameter(request, "maLoaiPhong");
        String ten = getParameter(request, "tenLoaiPhong");

        if (ma.isEmpty() || ten.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/phong-chieu/view?openModal=loaiPhong&lpMsg=empty");
            return;
        }

        boolean ok = loaiPhongRepo.update(new LoaiPhong(ma, ten));
        response.sendRedirect(request.getContextPath() + "/phong-chieu/view?openModal=loaiPhong&lpMsg=" + (ok ? "update_ok" : "error"));
    }

    // ==================== QUẢN LÝ PHÒNG CHIẾU ====================

    // Validate đầu vào, kiểm tra trùng tên phòng, rồi thêm mới phòng chiếu.
    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tenPhong = getParameter(request, "tenPhong");
        String loaiPhong = getParameter(request, "loaiPhong");
        String sucChuaStr = getParameter(request, "sucChua");

        Integer sucChua = null;
        String error = null;

        if (tenPhong.isEmpty() || loaiPhong.isEmpty() || sucChuaStr.isEmpty()) {
            error = "Vui lòng nhập đầy đủ tất cả các trường bắt buộc!";
        }

        // Parse và kiểm tra sức chứa phải là số nguyên dương.
        if (error == null) {
            try {
                sucChua = Integer.parseInt(sucChuaStr);
                if (sucChua <= 0) error = "Sức chứa phải là số nguyên lớn hơn 0!";
            } catch (NumberFormatException e) {
                error = "Sức chứa phải là một số nguyên hợp lệ!";
            }
        }

        // Chặn trùng tên phòng trong toàn hệ thống.
        if (error == null && repo.existsByTenPhong(tenPhong, null)) {
            error = "Tên phòng chiếu [" + tenPhong + "] đã tồn tại!";
        }

        PhongChieu pc = new PhongChieu(tenPhong, loaiPhong, sucChua);

        if (error != null) {
            forwardToView(request, response, pc, "add", error);
            return;
        }

        boolean result = repo.add(pc);
        if (!result) {
            forwardToView(request, response, pc, "add", "Thêm phòng chiếu thất bại! Vui lòng kiểm tra kết nối cơ sở dữ liệu.");
            return;
        }
        if (pc.getMaPhong() != null) {
            dinhDangRepo.savePhongDinhDang(pc.getMaPhong(), parseDinhDangIds(request));
        }

        response.sendRedirect(request.getContextPath() + "/phong-chieu/view");
    }

    // Validate đầu vào, kiểm tra tồn tại và trùng tên, rồi lưu thay đổi phòng chiếu.
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String maPhongStr = getParameter(request, "maPhong");
        String tenPhong = getParameter(request, "tenPhong");
        String loaiPhong = getParameter(request, "loaiPhong");
        String sucChuaStr = getParameter(request, "sucChua");

        Integer maPhong = null;
        Integer sucChua = null;
        String error = null;

        if (maPhongStr.isEmpty() || tenPhong.isEmpty() || loaiPhong.isEmpty() || sucChuaStr.isEmpty()) {
            error = "Vui lòng nhập đầy đủ tất cả các trường bắt buộc!";
        }

        // Parse mã phòng.
        if (error == null) {
            try {
                maPhong = Integer.parseInt(maPhongStr);
            } catch (NumberFormatException e) {
                error = "Mã phòng không hợp lệ!";
            }
        }

        // Parse và kiểm tra sức chứa phải là số nguyên dương.
        if (error == null) {
            try {
                sucChua = Integer.parseInt(sucChuaStr);
                if (sucChua <= 0) error = "Sức chứa phải là số nguyên lớn hơn 0!";
            } catch (NumberFormatException e) {
                error = "Sức chứa phải là một số nguyên hợp lệ!";
            }
        }

        // Kiểm tra phòng chiếu còn tồn tại trong CSDL.
        if (error == null && repo.getById(maPhong) == null) {
            error = "Phòng chiếu không tồn tại hoặc đã bị xóa!";
        }

        // Chặn trùng tên phòng (loại trừ chính phòng đang sửa).
        if (error == null && repo.existsByTenPhong(tenPhong, maPhong)) {
            error = "Tên phòng chiếu [" + tenPhong + "] đã tồn tại!";
        }

        PhongChieu pc = new PhongChieu(maPhong, tenPhong, loaiPhong, sucChua);

        if (error != null) {
            forwardToView(request, response, pc, "update", error);
            return;
        }

        boolean result = repo.update(pc);
        if (!result) {
            forwardToView(request, response, pc, "update", "Cập nhật phòng chiếu thất bại! Vui lòng kiểm tra cơ sở dữ liệu.");
            return;
        }
        dinhDangRepo.savePhongDinhDang(maPhong, parseDinhDangIds(request));

        response.sendRedirect(request.getContextPath() + "/phong-chieu/view");
    }

    // ==================== HÀM HỖ TRỢ ====================

    // Tính phân trang (5 phòng/trang) và nạp dữ liệu danh sách, loại phòng vào request.
    private void loadDataPaging(HttpServletRequest request) {
        int page = 1;
        int pageSize = 5;

        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        List<PhongChieu> allList = repo.getAll();
        int totalItems = allList.size();

        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages <= 0) totalPages = 1;
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        int startIndex = (page - 1) * pageSize;
        int endIndex = Math.min(startIndex + pageSize, totalItems);

        List<PhongChieu> pagedList = startIndex < totalItems
                ? allList.subList(startIndex, endIndex)
                : Collections.emptyList();

        request.setAttribute("listPhongChieu", pagedList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("listLoaiPhong", new LoaiPhongRepository().getAll());
        request.setAttribute("listDinhDang", dinhDangRepo.getAll());
    }

    private List<Integer> parseDinhDangIds(HttpServletRequest request) {
        List<Integer> ids = new ArrayList<>();
        String[] vals = request.getParameterValues("dinhDangIds");
        if (vals != null) {
            for (String v : vals) {
                try {
                    ids.add(Integer.parseInt(v.trim()));
                } catch (NumberFormatException ignored) {}
            }
        }
        return ids;
    }

    // Đọc tham số request, trả về chuỗi rỗng nếu null, cắt khoảng trắng hai đầu.
    private String getParameter(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value != null ? value.trim() : "";
    }

    // Forward về JSP kèm thông báo lỗi và mở lại modal tương ứng.
    private void forwardToView(HttpServletRequest request, HttpServletResponse response,
                               PhongChieu pc, String openModal, String error)
            throws ServletException, IOException {

        request.setAttribute("pc", pc);
        request.setAttribute("openModal", openModal);
        request.setAttribute("error", error);
        loadDataPaging(request);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
