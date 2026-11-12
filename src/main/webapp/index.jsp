<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<<<<<<< HEAD
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Rạp Phim - Chọn vai trò</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=7">
</head>
<body>
<div class="portal-page">
    <div class="portal-header">
        <span class="portal-badge">QUẢN LÝ RẠP PHIM TẠI QUẦY</span>
        <h1>Hệ thống <span style="color: var(--pink);">Rạp Chiếu Phim</span></h1>
        <p>Chọn giao diện làm việc cho Quản lý hoặc Nhân viên quầy.</p>
    </div>

    <div class="role-cards">
        <div class="role-card">
            <h2>Trang chủ Quản lý</h2>
            <p>Menu điều hành: Tổng quan, Quản lí phim (Thể loại), Phòng ghế, Lịch chiếu bán vé.</p>
            <a href="menuadmin.jsp" class="btn btn-pink" style="margin-top: auto;">Vào trang Quản lý</a>
        </div>

        <div class="role-card">
            <h2>Trang chủ Nhân viên</h2>
            <p>Menu thao tác quầy dành cho nhân viên bán vé và tra cứu lịch chiếu, phòng ghế.</p>
            <a href="menunv.jsp" class="btn btn-outline" style="margin-top: auto; border-color: var(--pink); color: var(--pink);">Vào trang Nhân viên</a>
        </div>
    </div>
</div>
</body>
</html>
=======
<%
    // Tự động chuyển hướng vào trang đăng nhập
    response.sendRedirect(request.getContextPath() + "/login");
%>
>>>>>>> origin/main
