package controller;

import entity.LoaiPhong;
import entity.PhongChieu;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.LoaiPhongRepository;
import repository.PhongChieuRepository;

import java.io.IOException;
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

    private static final String VIEW = "/Phong-Chieu/view.jsp";
    private static final String VIEW_UPDATE = "/Phong-Chieu/view-update.jsp";

    // Tiếp nhận và điều hướng các yêu cầu GET (xem danh sách, chi tiết, mở form sửa, xóa loại phòng)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if (path.equals("/phong-chieu/loai-phong-delete")) {
            handleDeleteLoaiPhong(request, response);
            return;
        }

        // Hiển thị danh sách phòng chiếu có phân trang (5 phòng / 1 trang)
        if (path.equals("/phong-chieu/view")) {

            loadDataPaging(request);
            request.getRequestDispatcher(VIEW).forward(request, response);

        }
        else if (path.equals("/phong-chieu/detail")) {

            String maPhong = getParameter(request, "id");
            PhongChieu pc = repo.getById(maPhong);

            if (pc == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Không tìm thấy phòng chiếu!"
                );
                return;
            }

            request.setAttribute("pc", pc);
            request.setAttribute("openModal", "detail");
            loadDataPaging(request);

            request.getRequestDispatcher(VIEW).forward(request, response);

        }
        else if (path.equals("/phong-chieu/view-update")) {

            String maPhong = getParameter(request, "id");
            PhongChieu pc = repo.getById(maPhong);

            if (pc == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Không tìm thấy phòng chiếu cần cập nhật!"
                );
                return;
            }

            request.setAttribute("pc", pc);
            loadDataPaging(request);

            request.getRequestDispatcher(VIEW_UPDATE).forward(request, response);

        }
        else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // Tiếp nhận và phân phối các form POST (thêm/sửa phòng chiếu, thêm/sửa loại phòng)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        if (path.equals("/phong-chieu/add")) {
            handleAdd(request, response);
        }
        else if (path.equals("/phong-chieu/update")) {
            handleUpdate(request, response);
        }
        else if (path.equals("/phong-chieu/loai-phong-add")) {
            handleAddLoaiPhong(request, response);
        }
        else if (path.equals("/phong-chieu/loai-phong-update")) {
            handleUpdateLoaiPhong(request, response);
        }
        else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ==================== QUẢN LÝ LOẠI PHÒNG (CRUD TRONG PHÒNG CHIẾU) ====================
    // Xóa một loại phòng sau khi kiểm tra không có phòng chiếu nào đang sử dụng
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

    // Kiểm tra dữ liệu hợp lệ và thêm mới một loại phòng chiếu
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

    // Kiểm tra dữ liệu và cập nhật thông tin loại phòng chiếu
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

    // Kiểm tra dữ liệu đầu vào và thêm mới phòng chiếu vào database
    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String maPhong = getParameter(request, "maPhong");
        String tenPhong = getParameter(request, "tenPhong");
        String loaiPhong = getParameter(request, "loaiPhong");
        String sucChuaStr = getParameter(request, "sucChua");

        Integer sucChua = null;
        String error = null;

        if (maPhong.isEmpty()
                || tenPhong.isEmpty()
                || loaiPhong.isEmpty()
                || sucChuaStr.isEmpty()) {
            error = "Vui lòng nhập đầy đủ tất cả các trường bắt buộc!";
        }

        // Kiểm tra sức chứa
        if (error == null) {
            try {
                sucChua = Integer.parseInt(sucChuaStr);
                if (sucChua <= 0) {
                    error = "Sức chứa phải là số nguyên lớn hơn 0!";
                }
            } catch (NumberFormatException e) {
                error = "Sức chứa phải là một số nguyên hợp lệ!";
            }
        }

        if (error == null) {
            if (repo.getById(maPhong) != null) {
                error = "Mã phòng chiếu [" + maPhong + "] đã tồn tại!";
            } else if (repo.existsByTenPhong(tenPhong, null)) {
                error = "Tên phòng chiếu [" + tenPhong + "] đã tồn tại!";
            }
        }

        PhongChieu pc = new PhongChieu(
                maPhong,
                tenPhong,
                loaiPhong,
                sucChua
        );

        if (error != null) {
            forwardToView(request, response, pc, "add", error);
            return;
        }

        // Thực hiện thêm
        boolean result = repo.add(pc);

        if (!result) {
            forwardToView(
                    request,
                    response,
                    pc,
                    "add",
                    "Thêm phòng chiếu thất bại! Vui lòng kiểm tra kết nối cơ sở dữ liệu."
            );
            return;
        }

        // Thêm thành công, quay lại danh sách
        response.sendRedirect(request.getContextPath() + "/phong-chieu/view");
    }

    // Kiểm tra tính hợp lệ của dữ liệu và cập nhật phòng chiếu
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String maPhong = getParameter(request, "maPhong");
        String tenPhong = getParameter(request, "tenPhong");
        String loaiPhong = getParameter(request, "loaiPhong");
        String sucChuaStr = getParameter(request, "sucChua");

        Integer sucChua = null;
        String error = null;

        // Kiểm tra dữ liệu rỗng
        if (maPhong.isEmpty()
                || tenPhong.isEmpty()
                || loaiPhong.isEmpty()
                || sucChuaStr.isEmpty()) {
            error = "Vui lòng nhập đầy đủ tất cả các trường bắt buộc!";
        }

        // Kiểm tra sức chứa
        if (error == null) {
            try {
                sucChua = Integer.parseInt(sucChuaStr);
                if (sucChua <= 0) {
                    error = "Sức chứa phải là số nguyên lớn hơn 0!";
                }
            } catch (NumberFormatException e) {
                error = "Sức chứa phải là một số nguyên hợp lệ!";
            }
        }

        // Kiểm tra phòng chiếu có tồn tại không
        if (error == null) {
            if (repo.getById(maPhong) == null) {
                error = "Phòng chiếu không tồn tại hoặc đã bị xóa!";
            }
        }

        // Kiểm tra trùng tên phòng, loại trừ chính phòng đang sửa
        if (error == null && repo.existsByTenPhong(tenPhong, maPhong)) {
            error = "Tên phòng chiếu [" + tenPhong + "] đã tồn tại!";
        }

        // Tạo đối tượng phòng chiếu sau khi kiểm tra
        PhongChieu pc = new PhongChieu(
                maPhong,
                tenPhong,
                loaiPhong,
                sucChua
        );

        // Nếu có lỗi thì mở lại popup cập nhật
        if (error != null) {
            forwardToView(request, response, pc, "update", error);
            return;
        }

        // Thực hiện cập nhật
        boolean result = repo.update(pc);

        if (!result) {
            forwardToView(
                    request,
                    response,
                    pc,
                    "update",
                    "Cập nhật phòng chiếu thất bại! Vui lòng kiểm tra cơ sở dữ liệu."
            );
            return;
        }

        // Cập nhật thành công
        response.sendRedirect(request.getContextPath() + "/phong-chieu/view");
    }

    // ==================== HÀM HỖ TRỢ PHÂN TRANG (5 PHÒNG / 1 TRANG) ====================
    // Tính toán phân trang và nạp danh sách 5 phòng chiếu cho trang hiện tại
    private void loadDataPaging(HttpServletRequest request) {
        int page = 1;
        int pageSize = 5; // Cố định 5 phòng chiếu trên 1 trang

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

        // Tính tổng số trang: ví dụ 12 phòng / 5 = 3 trang
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages <= 0) {
            totalPages = 1;
        }

        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        // Cắt lấy 5 phần tử tương ứng với trang hiện tại
        int startIndex = (page - 1) * pageSize;
        int endIndex = Math.min(startIndex + pageSize, totalItems);

        List<PhongChieu> pagedList;
        if (startIndex < totalItems) {
            pagedList = allList.subList(startIndex, endIndex);
        } else {
            pagedList = Collections.emptyList();
        }

        request.setAttribute("listPhongChieu", pagedList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("listLoaiPhong", new repository.LoaiPhongRepository().getAll());
    }

    // Đọc tham số từ request và loại bỏ khoảng trắng thừa hai đầu
    private String getParameter(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value != null ? value.trim() : "";
    }

    // Chuyển tiếp về giao diện JSP kèm thông báo lỗi và giữ lại dữ liệu đang nhập
    private void forwardToView(
            HttpServletRequest request,
            HttpServletResponse response,
            PhongChieu pc,
            String openModal,
            String error
    ) throws ServletException, IOException {

        request.setAttribute("pc", pc);
        request.setAttribute("openModal", openModal);
        request.setAttribute("error", error);
        loadDataPaging(request);

        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
