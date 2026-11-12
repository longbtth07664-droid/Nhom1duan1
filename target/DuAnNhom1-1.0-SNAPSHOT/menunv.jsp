<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu Nhân viên - Rạp Chiếu Phim</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=7">
</head>
<body>
<div class="app-shell">
    <!-- MENU BÊN TRÁI -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">

            <div class="brand-text">
                <h1>Rạp Chiếu Phim CINEMAX</h1>
                <span>Nhân viên quầy</span>
            </div>
        </div>

        <nav class="sidebar-menu">
            <div class="menu-group-label">Menu quầy vé</div>

            <a href="#" class="nav-item active">
                <span>Lịch chiếu bán vé</span>
            </a>

            <a href="#" class="nav-item">
                <span>Phòng ghế</span>
            </a>
        </nav>

        <div class="sidebar-footer">
            <div class="user-card">
                <div class="user-avatar">NV</div>
                <div class="user-info">
                    <div class="name">Nhân viên quầy</div>
                    <div class="role">Thu ngân</div>
                </div>
            </div>
            <a href="menuadmin.jsp" class="role-switch-link">Chuyển sang Quản lý</a>
            <a href="index.jsp" class="role-switch-link">Trang chủ chọn vai trò</a>
        </div>
    </aside>
</div>

<script src="assets/js/cinema-mock.js?v=3"></script>
</body>
</html>
