<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu Quản lý - Rạp Chiếu Phim</title>
    <link rel="stylesheet" href="assets/css/cinema-theme.css?v=3">
</head>
<body>
<div class="app-shell">
    <!-- MENU BÊN TRÁI -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            
            <div class="brand-text">
                <h1>Rạp Chiếu Phim CINEMAX</h1>
                <span>Quản lý</span>
            </div>
        </div>

        <nav class="sidebar-menu">
            <div class="menu-group-label">Menu chức năng</div>

            <a href="#" class="nav-item active">
                <span>Tổng quan</span>
            </a>

            <div class="nav-group">
                <button type="button" class="nav-item nav-parent" onclick="toggleSubmenu(this)">
                    <span>Quản lí phim</span>
                    <span class="nav-arrow">▾</span>
                </button>
                <div class="nav-submenu">
                    <a href="#" class="nav-subitem">Danh sách phim</a>
                    <a href="#" class="nav-subitem">Quản lí thể loại</a>
                </div>
            </div>

            <a href="#" class="nav-item">
                <span>Phòng ghế</span>
            </a>

            <a href="#" class="nav-item">
                <span>Lịch chiếu bán vé</span>
            </a>
        </nav>

        <div class="sidebar-footer">
            <div class="user-card">
                <div class="user-avatar">QL</div>
                <div class="user-info">
                    <div class="name">Quản lý rạp</div>
                    <div class="role">Admin</div>
                </div>
            </div>
            <a href="menunv.jsp" class="role-switch-link">Chuyển sang Nhân viên</a>
            <a href="index.jsp" class="role-switch-link">Trang chủ chọn vai trò</a>
        </div>
    </aside>
</div>

<script src="assets/js/cinema-mock.js?v=3"></script>
</body>
</html>
