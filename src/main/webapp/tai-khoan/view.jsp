<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý tài khoản - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=7">
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

            <a href="${pageContext.request.contextPath}/menuadmin.jsp" class="nav-item">
                <span>Tổng quan</span>
            </a>

            <div class="nav-group">
                <button type="button" class="nav-item nav-parent" onclick="toggleSubmenu(this)">
                    <span>Quản lí phim</span>
                    <span class="nav-arrow">▾</span>
                </button>
                <div class="nav-submenu">
                    <a href="#" class="nav-subitem">Danh sách phim</a>
                    <a href="${pageContext.request.contextPath}/the-loai/view" class="nav-subitem">Quản lí thể loại</a>
                </div>
            </div>

            <a href="${pageContext.request.contextPath}/phong-chieu/view" class="nav-item">
                <span>Phòng ghế</span>
            </a>

            <a href="${pageContext.request.contextPath}/nhan-vien/view" class="nav-item">
                <span>Quản lý nhân viên</span>
            </a>

            <!-- Mục Quản lý tài khoản đang active -->
            <a href="${pageContext.request.contextPath}/tai-khoan/view" class="nav-item active">
                <span>Quản lý tài khoản</span>
            </a>

            <a href="#" class="nav-item">
                <span>Lịch chiếu bán vé</span>
            </a>
        </nav>

        <div class="sidebar-footer">
            <div class="user-card">
                <div class="user-avatar">QL</div>
                <div class="user-info">
                    <div class="name"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Quản lý rạp" %></div>
                    <div class="role"><%= session.getAttribute("userRole") != null ? session.getAttribute("userRole") : "Admin" %></div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="role-switch-link" style="color: #ff4757; margin-top: 8px;">Đăng xuất</a>
        </div>
    </aside>

    <!-- NỘI DUNG CHÍNH -->
    <div class="main-wrapper">
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Quản lý tài khoản</h2>
                </div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/menuadmin.jsp" class="btn btn-ghost btn-sm">Menu chính</a>
            </div>
        </header>

        <main class="content-area">
            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Danh sách tài khoản hệ thống</div>
                        <div class="card-subtitle">Mật khẩu được ẩn ngoài danh sách, bấm Chi tiết để xem thông tin đăng nhập và email</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <span class="badge-pink">${listTaiKhoan.size()} tài khoản</span>
                    </div>
                </div>

                <!-- Bảng danh sách -->
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>STT</th>
                            <th>MÃ TK</th>
                            <th>HỌ TÊN</th>
                            <th>USERNAME</th>
                            <th>PASSWORD</th>
                            <th>VAI TRÒ</th>
                            <th>TRẠNG THÁI</th>
                            <th>HÀNH ĐỘNG</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${listTaiKhoan}" var="tk" varStatus="status">
                            <tr>
                                <td>${status.index + 1}</td>
                                <td><strong><c:out value="${tk.maTK}"/></strong></td>
                                <td><c:out value="${tk.hoTen}"/></td>
                                <td><c:out value="${tk.username}"/></td>
                                <!-- Ẩn mật khẩu trên bảng danh sách -->
                                <td style="letter-spacing: 2px; color: #868e96;">••••••••</td>
                                <td>
                                    <span style="padding: 4px 8px; border-radius: 4px; font-size: 12px; background: ${tk.vaiTro == 'QuanLy' ? '#ffe3e3; color: #c92a2a;' : '#e7f5ff; color: #1864ab;'};">
                                        <c:out value="${tk.vaiTro}"/>
                                    </span>
                                </td>
                                <td><c:out value="${tk.trangThai}"/></td>
                                <td>
                                    <div class="action-group">
                                        <!-- Nút Chi tiết -->
                                        <button type="button" class="btn btn-ghost btn-sm"
                                                data-id="<c:out value='${tk.maTK}'/>"
                                                data-hoten="<c:out value='${tk.hoTen}'/>"
                                                data-email="<c:out value='${tk.email}'/>"
                                                data-username="<c:out value='${tk.username}'/>"
                                                data-password="<c:out value='${tk.password}'/>"
                                                data-vaitro="<c:out value='${tk.vaiTro}'/>"
                                                data-trangthai="<c:out value='${tk.trangThai}'/>"
                                                onclick="openDetailModal(event, this)">Chi tiết</button>

                                        <!-- Nút Sửa -->
                                        <a href="${pageContext.request.contextPath}/tai-khoan/view-update?id=${tk.maTK}" class="btn btn-outline btn-sm">Sửa</a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- ================= MODAL CHI TIẾT TÀI KHOẢN ================= -->
<div class="modal-backdrop" id="detailModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Chi tiết tài khoản hệ thống</h3>
            <button type="button" class="modal-close" onclick="closeModal('detailModal')">&times;</button>
        </div>
        <div class="form-stack">
            <div class="form-group">
                <label>Mã tài khoản</label>
                <div class="form-control" style="background:var(--bg-input); font-weight: bold;" id="detailId"></div>
            </div>
            <div class="form-group">
                <label>Họ Tên</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailHoTen"></div>
            </div>
            <div class="form-group">
                <label>Email</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailEmail"></div>
            </div>
            <div class="form-group">
                <label>Username</label>
                <div class="form-control" style="background:var(--bg-input); font-weight: bold;" id="detailUsername"></div>
            </div>
            <div class="form-group">
                <label>Password</label>
                <div class="form-control" style="background:var(--bg-input); color: #c92a2a; font-weight: bold;" id="detailPassword"></div>
            </div>
            <div class="form-group">
                <label>Vai Trò</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailVaiTro"></div>
            </div>
            <div class="form-group">
                <label>Trạng Thái</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailTrangThai"></div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-pink" onclick="closeModal('detailModal')">Đóng</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=5"></script>
<script>
    function openDetailModal(event, btn) {
        if (event) event.preventDefault();

        document.getElementById('detailId').textContent = btn.getAttribute('data-id');
        document.getElementById('detailHoTen').textContent = btn.getAttribute('data-hoten');
        document.getElementById('detailEmail').textContent = btn.getAttribute('data-email');
        document.getElementById('detailUsername').textContent = btn.getAttribute('data-username');
        document.getElementById('detailPassword').textContent = btn.getAttribute('data-password');
        document.getElementById('detailVaiTro').textContent = btn.getAttribute('data-vaitro');
        document.getElementById('detailTrangThai').textContent = btn.getAttribute('data-trangthai');

        document.getElementById('detailModal').classList.add('open');
    }

    function closeModal(modalId) {
        document.getElementById(modalId).classList.remove('open');
    }
</script>
</body>
</html>