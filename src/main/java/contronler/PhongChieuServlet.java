package contronler;

import entity.PhongChieu;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.PhongChieuRepository;

import java.io.IOException;

@WebServlet(name = "PhongChieuServlet", urlPatterns = {
        "/phong-chieu/view",
        "/phong-chieu/detail",
        "/phong-chieu/view-update",
        "/phong-chieu/add",
        "/phong-chieu/update"
})
public class PhongChieuServlet extends HttpServlet {

    private final PhongChieuRepository repo = new PhongChieuRepository();

    private static final String VIEW = "/Phong-Chieu/view.jsp";
    private static final String VIEW_UPDATE = "/Phong-Chieu/view-update.jsp";
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        // Hiển thị danh sách phòng chiếu
        if (path.equals("/phong-chieu/view")) {

            request.setAttribute("listPhongChieu", repo.getAll());

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
            request.setAttribute("listPhongChieu", repo.getAll());

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
            request.setAttribute("listPhongChieu", repo.getAll());

            request.getRequestDispatcher(VIEW_UPDATE).forward(request, response);

        }

        else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

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

        else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }


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
        response.sendRedirect(
                request.getContextPath() + "/phong-chieu/view"
        );
    }

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
        response.sendRedirect(
                request.getContextPath() + "/phong-chieu/view"
        );
    }

    // ==================== HÀM HỖ TRỢ ====================

    // Lấy dữ liệu từ form và loại bỏ khoảng trắng
    private String getParameter(HttpServletRequest request, String name) {

        String value = request.getParameter(name);

        return value != null ? value.trim() : "";
    }

    // Quay lại trang danh sách và giữ dữ liệu khi có lỗi
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
        request.setAttribute("listPhongChieu", repo.getAll());

        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}