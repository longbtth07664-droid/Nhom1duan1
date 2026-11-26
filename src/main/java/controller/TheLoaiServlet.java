package controller;

import entity.TheLoai;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.TheLoaiRepository;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "TheLoaiServlet", value = {
        "/the-loai/view",        // GET
        "/the-loai/detail",      // GET
        "/the-loai/view-update", // GET
        "/the-loai/update",      // POST
        "/the-loai/add"          // POST
})
public class TheLoaiServlet extends HttpServlet {
    private final TheLoaiRepository repo = new TheLoaiRepository();

    // [PHÂN TRANG - BACKEND] Số lượng thể loại hiển thị trên mỗi trang (5 dòng/trang)
    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();
        if (uri.contains("view-update")) {
            viewUpdate(req, resp);
        } else if (uri.contains("detail")) {
            detail(req, resp);
        } else {
            view(req, resp);
        }
    }

    // =========================================================================
    // [PHÂN TRANG - BACKEND] Hàm xử lý tính toán số trang và nạp dữ liệu phân trang
    // =========================================================================
    private void napDuLieuPhanTrang(HttpServletRequest req) {
        // 1. Đọc số trang người dùng muốn xem từ URL (VD: ?page=2). Mặc định là trang 1
        int page = 1;
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        // 2. Lấy tổng số thể loại hiện có trong Database
        long totalItems = repo.countAll();

        // 3. Tính tổng số trang (totalPages = làm tròn lên của totalItems / PAGE_SIZE)
        int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);
        if (totalPages <= 0) totalPages = 1;

        // Giới hạn số trang hợp lệ trong khoảng từ 1 đến totalPages
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        // 4. Lấy danh sách thể loại của trang hiện tại (chỉ lấy đúng 5 bản ghi)
        List<TheLoai> listTheLoai = repo.getPagination(page, PAGE_SIZE);

        // 5. Gửi các thông số phân trang sang file view.jsp
        req.setAttribute("listTheLoai", listTheLoai);     // Danh sách thể loại của trang này
        req.setAttribute("currentPage", page);           // Trang hiện tại
        req.setAttribute("totalPages", totalPages);       // Tổng số trang
        req.setAttribute("totalItems", totalItems);       // Tổng số bản ghi
    }

    private void view(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        napDuLieuPhanTrang(req);
        req.getRequestDispatcher("/the-loai/view.jsp").forward(req, resp);
    }

    private void detail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        TheLoai tl = repo.getOne(id);
        req.setAttribute("tl", tl);
        req.setAttribute("openModal", "detail");
        napDuLieuPhanTrang(req);
        req.getRequestDispatcher("/the-loai/view.jsp").forward(req, resp);
    }

    private void viewUpdate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        TheLoai tl = repo.getOne(id);
        req.setAttribute("tl", tl);
        req.setAttribute("openModal", "update");
        napDuLieuPhanTrang(req);
        req.getRequestDispatcher("/the-loai/view.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String uri = req.getRequestURI();
        if (uri.contains("add")) {
            add(req, resp);
        } else if (uri.contains("update")) {
            update(req, resp);
        }
    }

    private void add(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String ten = req.getParameter("tenTheLoai") != null ? req.getParameter("tenTheLoai").trim() : "";

        if (ten.isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập Tên thể loại!");
            TheLoai tl = new TheLoai();
            tl.setTenTheLoai(ten);
            req.setAttribute("tl", tl);
            req.setAttribute("openModal", "add");
            view(req, resp);
            return;
        }

        TheLoai tl = new TheLoai();
        tl.setTenTheLoai(ten);
        repo.add(tl);
        resp.sendRedirect(req.getContextPath() + "/the-loai/view");
    }

    private void update(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String ma = req.getParameter("maTheLoai") != null ? req.getParameter("maTheLoai").trim() : "";
        String ten = req.getParameter("tenTheLoai") != null ? req.getParameter("tenTheLoai").trim() : "";

        Integer id = null;
        try {
            id = Integer.parseInt(ma);
        } catch (NumberFormatException ignored) {}

        if (id == null || ten.isEmpty()) {
            req.setAttribute("error", "Tên thể loại không được để trống!");
            TheLoai tl = new TheLoai();
            tl.setMaTheLoai(id);
            tl.setTenTheLoai(ten);
            req.setAttribute("tl", tl);
            req.setAttribute("openModal", "update");
            req.setAttribute("listTheLoai", repo.getAll());
            req.getRequestDispatcher("/the-loai/view.jsp").forward(req, resp);
            return;
        }

        TheLoai tl = new TheLoai(id, ten);
        repo.update(tl);
        resp.sendRedirect(req.getContextPath() + "/the-loai/view");
    }
}
