<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu Nhân viên - Rạp Chiếu Phim</title>
    <link rel="stylesheet" href="assets/css/cinema-theme.css?v=3">
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
                <div class="user-avatar"><%= session.getAttribute("userName") != null ? session.getAttribute("userName").toString().substring(0, 1).toUpperCase() : "NV" %></div>
                <div class="user-info">
                    <div class="name"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Nhân viên quầy" %></div>
                    <div class="role"><%= session.getAttribute("userRole") != null ? session.getAttribute("userRole") : "NhanVien" %></div>
                </div>
            </div>
            <a href="<%= request.getContextPath() %>/logout" class="role-switch-link" style="color: #ff4757; margin-top: 8px;">Đăng xuất</a>
        </div>
    </aside>
</div>

<script src="assets/js/cinema-mock.js?v=3"></script>
</body>
</html>
