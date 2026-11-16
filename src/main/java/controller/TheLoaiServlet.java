package controller;

import entity.TheLoai;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.TheLoaiRepository;

import java.io.IOException;

@WebServlet(name = "TheLoaiServlet", value = {
        "/the-loai/view",        // GET
        "/the-loai/detail",      // GET
        "/the-loai/view-update", // GET
        "/the-loai/update",      // POST
        "/the-loai/add"          // POST
})
public class TheLoaiServlet extends HttpServlet {
    private final TheLoaiRepository repo = new TheLoaiRepository();

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

    private void view(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("listTheLoai", repo.getAll());
        req.getRequestDispatcher("/the-loai/view.jsp").forward(req, resp);
    }

    private void detail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        TheLoai tl = repo.getOne(id);
        req.setAttribute("tl", tl);
        req.setAttribute("openModal", "detail");
        req.setAttribute("listTheLoai", repo.getAll());
        req.getRequestDispatcher("/the-loai/view.jsp").forward(req, resp);
    }

    private void viewUpdate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        TheLoai tl = repo.getOne(id);
        req.setAttribute("tl", tl);
        req.setAttribute("openModal", "update");
        req.setAttribute("listTheLoai", repo.getAll());
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
