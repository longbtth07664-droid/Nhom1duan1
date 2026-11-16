package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "LoaiPhongServlet", urlPatterns = {
        "/loai-phong/view",
        "/loai-phong"
})
public class LoaiPhongServlet extends HttpServlet {

    // Điều hướng về màn hình phòng chiếu và tự động bật popup Quản lý loại phòng
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/phong-chieu/view?openModal=loaiPhong");
    }

    // Chuyển tiếp request POST sang xử lý tương tự như GET
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
