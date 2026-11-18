<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lí khách hàng - Rạp Chiếu Phim CINEMAX</title>
    <!-- Nhúng file CSS giao diện chung của rạp phim CINEMAX -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=8">
    <style>
        /* Định dạng hộp thoại popup nổi ở giữa màn hình */
        .modal-backdrop {
            position: fixed !important;
            top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important;
            width: 100vw !important; height: 100vh !important;
            background: rgba(15, 23, 42, 0.55) !important;
            backdrop-filter: blur(4px) !important;
            display: none !important;
            align-items: center !important; justify-content: center !important;
            z-index: 9999 !important; padding: 20px !important;
        }
        .modal-backdrop.open { display: flex !important; }
        .modal-backdrop .modal-box {
            width: 100%; max-width: 480px;
            background: #ffffff; border-radius: 14px; padding: 22px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.25);
        }
    </style>
</head>
<body>
<div class="app-shell">
    <!-- MENU ĐIỀU HƯỚNG BÊN TRÁI -->
    <aside class="sidebar" id="sidebar">
        <!-- Logo thương hiệu rạp phim CINEMAX -->
        <div class="sidebar-brand">
            <div class="brand-text">
                <h1>Rạp Chiếu Phim CINEMAX</h1>
                <span>Quản lý</span>
            </div>
        </div>

        <!-- Danh sách các chức năng trên sidebar menu -->
        <nav class="sidebar-menu">
            <div class="menu-group-label">Menu chức năng</div>

            <!-- Bảng tổng quan -->
            <%-- [Ghi chú - Khánh]: Điều hướng Tổng quan về /thong-ke --%>
            <a href="${pageContext.request.contextPath}/thong-ke" class="nav-item">
                <span>Tổng quan</span>
            </a>

            <!-- Nhóm quản lý Phòng và Ghế -->
            <div class="nav-group">
                <button type="button" class="nav-item nav-parent" onclick="toggleSubmenu(this)">
                    <span>Phòng ghế</span>
                    <span class="nav-arrow">▾</span>
                </button>
                <div class="nav-submenu">
                    <a href="${pageContext.request.contextPath}/phong-chieu/view" class="nav-subitem">Danh sách phòng chiếu</a>
                    <a href="${pageContext.request.contextPath}/ghe" class="nav-subitem">Sơ đồ & Quản lý ghế</a>
                </div>
            </div>

            <!-- Nhóm quản lý Phim và Thể loại -->
            <div class="nav-group">
                <button type="button" class="nav-item nav-parent" onclick="toggleSubmenu(this)">
                    <span>Quản lí phim</span>
                    <span class="nav-arrow">▾</span>
                </button>
                <div class="nav-submenu">
                    <a href="${pageContext.request.contextPath}/phim/view" class="nav-subitem">Danh sách phim</a>
                    <a href="${pageContext.request.contextPath}/the-loai/view" class="nav-subitem">Quản lí thể loại</a>
                </div>
            </div>

            <!-- Quản lý suất chiếu / lịch chiếu -->
            <a href="${pageContext.request.contextPath}/suat-chieu/view" class="nav-item">
                <span>Quản lý lịch chiếu</span>
            </a>

            <!-- Quản lý bắp nước sản phẩm -->
            <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="nav-item">
                <span>Quản lí sản phẩm</span>
            </a>

            <!-- Quản lý các gói Combo -->
            <a href="${pageContext.request.contextPath}/quan-ly-combo" class="nav-item">
                <span>Quản lí combo</span>
            </a>

            <!-- Quản lý thông tin khách hàng (đang kích hoạt) -->
            <a href="${pageContext.request.contextPath}/khach-hang/view" class="nav-item active">
                <span>Quản lí khách hàng</span>
            </a>

            <a href="${pageContext.request.contextPath}/hoa-don" class="nav-item">
                <span>Quản lí hóa đơn</span>
            </a>
        </nav>

        <!-- Chân trang sidebar hiển thị thông tin tài khoản đăng nhập -->
        <div class="sidebar-footer">
            <div class="user-card">
                <div class="user-avatar"><%= session.getAttribute("userName") != null ? session.getAttribute("userName").toString().substring(0, 1).toUpperCase() : "QL" %></div>
                <div class="user-info">
                    <div class="name"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Quản lý rạp" %></div>
                    <div class="role"><%= session.getAttribute("userRole") != null ? session.getAttribute("userRole") : "QuanLy" %></div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="role-switch-link" style="color: #ff4757; margin-top: 8px;">Đăng xuất</a>
        </div>
    </aside>

    <!-- NỘI DUNG CHÍNH CỦA TRANG -->
    <div class="main-wrapper">
        <!-- Thanh tiêu đề phía trên cùng -->
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Quản lí khách hàng</h2>
                </div>
            </div>
            <div class="topbar-right">
                <%-- [Ghi chú - Khánh]: Menu chính trỏ về Tổng quan /thong-ke --%>
                <a href="${pageContext.request.contextPath}/thong-ke" class="btn btn-ghost btn-sm">Menu chính</a>
            </div>
        </header>

        <!-- Khu vực hiển thị bảng dữ liệu khách hàng -->
        <main class="content-area">

            <!-- Thông báo trạng thái thao tác thành công -->
            <c:if test="${not empty successMsg}">
                <div style="background:#ecfdf5; border:1px solid #a7f3d0; color:#047857; padding:10px 16px; border-radius:6px; margin-bottom:14px; font-weight:500;">
                    ✓ <c:out value="${successMsg}"/>
                </div>
            </c:if>

            <!-- Thông báo trạng thái thao tác thất bại -->
            <c:if test="${not empty errorMsg}">
                <div style="background:#fef2f2; border:1px solid #fecaca; color:#dc2626; padding:10px 16px; border-radius:6px; margin-bottom:14px; font-weight:500;">
                    ✕ <c:out value="${errorMsg}"/>
                </div>
            </c:if>

            <!-- Khung card chứa danh sách khách hàng và thanh phân trang -->
            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Danh sách khách hàng</div>
                        <div class="card-subtitle">Hiển thị 5 khách hàng trên mỗi trang</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <button type="button" class="btn btn-pink" onclick="openAddKhachHang()">+ Thêm</button>
                        <span class="badge-pink">${totalItems} khách hàng</span>
                    </div>
                </div>

                <!-- Bảng dữ liệu chứa đầy đủ 5 cột thuộc tính trong CSDL -->
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>STT</th>
                            <th>Mã KH</th>
                            <th>Họ tên</th>
                            <th>Số điện thoại</th>
                            <th>Giới tính</th>
                            <th>Điểm tích lũy</th>
                            <th>Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${listKhachHang}" var="item" varStatus="st">
                            <tr>
                                <td>${(currentPage - 1) * 5 + st.index + 1}</td>
                                <td><strong><c:out value="${item.maKH}"/></strong></td>
                                <td><c:out value="${item.hoTen}"/></td>
                                <td><c:out value="${item.sdt}"/></td>
                                <td><c:out value="${item.gioiTinh}"/></td>
                                <td><c:out value="${item.diemTichLuy}"/> điểm</td>
                                <td>
                                    <div class="action-group">
                                        <!-- Nút mở popup xem chi tiết -->
                                        <button type="button"
                                                class="btn btn-ghost btn-sm"
                                                data-ma="<c:out value='${item.maKH}'/>"
                                                data-ten="<c:out value='${item.hoTen}'/>"
                                                data-sdt="<c:out value='${item.sdt}'/>"
                                                data-gioitinh="<c:out value='${item.gioiTinh}'/>"
                                                data-diem="<c:out value='${item.diemTichLuy}'/>"
                                                onclick="openDetailKhachHangFromBtn(this)">Chi tiết</button>

                                        <!-- Nút mở popup chỉnh sửa -->
                                        <button type="button"
                                                class="btn btn-outline btn-sm"
                                                data-ma="<c:out value='${item.maKH}'/>"
                                                data-ten="<c:out value='${item.hoTen}'/>"
                                                data-sdt="<c:out value='${item.sdt}'/>"
                                                data-gioitinh="<c:out value='${item.gioiTinh}'/>"
                                                data-diem="<c:out value='${item.diemTichLuy}'/>"
                                                onclick="openEditKhachHangFromBtn(this)">Sửa</button>

                                        <!-- Nút xóa khách hàng kèm xác nhận -->
                                        <button type="button"
                                                class="btn btn-sm"
                                                style="background:#fff1f2; color:#e11d48; border:1px solid #fda4af;"
                                                data-ma="<c:out value='${item.maKH}'/>"
                                                data-ten="<c:out value='${item.hoTen}'/>"
                                                data-context="${pageContext.request.contextPath}"
                                                onclick="confirmDeleteCustomer(this)">Xóa</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty listKhachHang}">
                            <tr>
                                <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 30px;">
                                    Chưa có khách hàng nào!
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- Thanh phân trang 5 khách hàng trên một trang -->
                <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 20px; border-top: 1px solid var(--border-subtle, #e2e8f0); flex-wrap: wrap; gap: 10px;">
                    <div style="color: var(--text-secondary); font-size: 13px;">
                        Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> (Tổng cộng: <strong>${totalItems}</strong> khách hàng)
                    </div>

                    <div style="display: flex; gap: 6px; align-items: center;">
                        <!-- Nút về trang đầu và trang trước -->
                        <c:if test="${currentPage > 1}">
                            <a href="${pageContext.request.contextPath}/khach-hang/view?page=1" class="btn btn-ghost btn-sm">&laquo; Đầu</a>
                            <a href="${pageContext.request.contextPath}/khach-hang/view?page=${currentPage - 1}" class="btn btn-ghost btn-sm">&lsaquo; Trước</a>
                        </c:if>

                        <!-- Các số trang 1, 2, 3... -->
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <a href="${pageContext.request.contextPath}/khach-hang/view?page=${p}"
                               class="btn btn-sm ${currentPage == p ? 'btn-pink' : 'btn-ghost'}"
                               style="min-width: 32px; justify-content: center; font-weight: ${currentPage == p ? '700' : '400'};">
                                ${p}
                            </a>
                        </c:forEach>

                        <!-- Nút sang trang sau và trang cuối -->
                        <c:if test="${currentPage < totalPages}">
                            <a href="${pageContext.request.contextPath}/khach-hang/view?page=${currentPage + 1}" class="btn btn-ghost btn-sm">Sau &rsaquo;</a>
                            <a href="${pageContext.request.contextPath}/khach-hang/view?page=${totalPages}" class="btn btn-ghost btn-sm">Cuối &raquo;</a>
                        </c:if>
                    </div>
                </div>

            </div>
        </main>
    </div>
</div>

<!-- ==================== POP-UP 1: THÊM KHÁCH HÀNG ==================== -->
<div class="modal-backdrop ${openModal == 'add' ? 'open' : ''}" id="addKhachHangModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Thêm khách hàng</h3>
            <button type="button" class="modal-close" onclick="closeModalDialog('addKhachHangModal')">&times;</button>
        </div>

        <!-- Thông báo lỗi khi nhập dữ liệu không hợp lệ -->
        <c:if test="${openModal == 'add' and not empty error}">
            <div id="addKhachHangError" style="background:#fef2f2; color:#dc2626; border:1px solid #fecaca; padding:10px 14px; border-radius:6px; margin-bottom:12px; font-size:13px; font-weight:600;">
                <c:out value="${error}"/>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/khach-hang/add" method="post">
            <div class="form-stack">
                <div class="form-group">
                    <label for="addMaKH">Mã khách hàng<span class="required-star">*</span></label>
                    <input type="text" id="addMaKH" name="maKH" class="form-control"
                           value="${openModal == 'add' ? kh.maKH : ''}"
                           placeholder="VD: KH001" required>
                </div>
                <div class="form-group">
                    <label for="addHoTen">Họ tên<span class="required-star">*</span></label>
                    <input type="text" id="addHoTen" name="hoTen" class="form-control"
                           value="${openModal == 'add' ? kh.hoTen : ''}"
                           placeholder="VD: Nguyễn Văn A" required>
                </div>
                <div class="form-group">
                    <label for="addSdt">Số điện thoại<span class="required-star">*</span></label>
                    <input type="text" id="addSdt" name="sdt" class="form-control"
                           value="${openModal == 'add' ? kh.sdt : ''}"
                           placeholder="VD: 0901234567" required>
                </div>
                <div class="form-group">
                    <label for="addGioiTinh">Giới tính</label>
                    <select id="addGioiTinh" name="gioiTinh" class="form-control">
                        <option value="Nam">Nam</option>
                        <option value="Nữ">Nữ</option>
                        <option value="Khác">Khác</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="addDiem">Điểm tích lũy</label>
                    <input type="number" id="addDiem" name="diemTichLuy" class="form-control" min="0"
                           value="${openModal == 'add' ? kh.diemTichLuy : '0'}"
                           placeholder="Mặc định: 0">
                </div>
            </div>
            <div class="modal-footer" style="display:flex; justify-content:flex-end; gap:8px; margin-top:16px;">
                <button type="button" class="btn btn-ghost" onclick="closeModalDialog('addKhachHangModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Thêm</button>
            </div>
        </form>
    </div>
</div>

<!-- ==================== POP-UP 2: SỬA KHÁCH HÀNG ==================== -->
<div class="modal-backdrop ${openModal == 'update' ? 'open' : ''}" id="editKhachHangModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Sửa thông tin khách hàng</h3>
            <button type="button" class="modal-close" onclick="closeModalDialog('editKhachHangModal')">&times;</button>
        </div>

        <!-- Thông báo lỗi khi cập nhật dữ liệu không hợp lệ -->
        <c:if test="${openModal == 'update' and not empty error}">
            <div id="editKhachHangError" style="background:#fef2f2; color:#dc2626; border:1px solid #fecaca; padding:10px 14px; border-radius:6px; margin-bottom:12px; font-size:13px; font-weight:600;">
                <c:out value="${error}"/>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/khach-hang/update" method="post">
            <div class="form-stack">
                <div class="form-group">
                    <label for="editMaKH">Mã khách hàng</label>
                    <input type="text" id="editMaKH" name="maKH" class="form-control"
                           value="${openModal == 'update' ? kh.maKH : ''}" readonly
                           style="background: #f1f5f9; color: var(--text-secondary);">
                </div>
                <div class="form-group">
                    <label for="editHoTen">Họ tên<span class="required-star">*</span></label>
                    <input type="text" id="editHoTen" name="hoTen" class="form-control"
                           value="${openModal == 'update' ? kh.hoTen : ''}" required>
                </div>
                <div class="form-group">
                    <label for="editSdt">Số điện thoại<span class="required-star">*</span></label>
                    <input type="text" id="editSdt" name="sdt" class="form-control"
                           value="${openModal == 'update' ? kh.sdt : ''}" required>
                </div>
                <div class="form-group">
                    <label for="editGioiTinh">Giới tính</label>
                    <select id="editGioiTinh" name="gioiTinh" class="form-control">
                        <option value="Nam">Nam</option>
                        <option value="Nữ">Nữ</option>
                        <option value="Khác">Khác</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="editDiem">Điểm tích lũy</label>
                    <input type="number" id="editDiem" name="diemTichLuy" class="form-control" min="0"
                           value="${openModal == 'update' ? kh.diemTichLuy : '0'}">
                </div>
            </div>
            <div class="modal-footer" style="display:flex; justify-content:flex-end; gap:8px; margin-top:16px;">
                <button type="button" class="btn btn-ghost" onclick="closeModalDialog('editKhachHangModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Lưu cập nhật</button>
            </div>
        </form>
    </div>
</div>

<!-- ==================== POP-UP 3: CHI TIẾT KHÁCH HÀNG ==================== -->
<div class="modal-backdrop" id="detailKhachHangModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Chi tiết khách hàng</h3>
            <button type="button" class="modal-close" onclick="closeModalDialog('detailKhachHangModal')">&times;</button>
        </div>
        <div class="form-stack">
            <div class="form-group">
                <label>Mã khách hàng</label>
                <div class="form-control" style="background:#f8fafc;" id="detailMaKH"></div>
            </div>
            <div class="form-group">
                <label>Họ tên</label>
                <div class="form-control" style="background:#f8fafc;" id="detailHoTen"></div>
            </div>
            <div class="form-group">
                <label>Số điện thoại</label>
                <div class="form-control" style="background:#f8fafc;" id="detailSdt"></div>
            </div>
            <div class="form-group">
                <label>Giới tính</label>
                <div class="form-control" style="background:#f8fafc;" id="detailGioiTinh"></div>
            </div>
            <div class="form-group">
                <label>Điểm tích lũy</label>
                <div class="form-control" style="background:#f8fafc;" id="detailDiem"></div>
            </div>
        </div>
        <div class="modal-footer" style="display:flex; justify-content:flex-end; margin-top:16px;">
            <button type="button" class="btn btn-pink" onclick="closeModalDialog('detailKhachHangModal')">Đóng</button>
        </div>
    </div>
</div>

<!-- Nhúng file JavaScript tương tác dùng chung của hệ thống -->
<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=8"></script>
<script>
    // Mở popup modal bằng cách thêm class open
    function openModalDialog(id) {
        const m = document.getElementById(id);
        if (m) m.classList.add('open');
    }

    // Đóng popup modal bằng cách gỡ bỏ class open
    function closeModalDialog(id) {
        const m = document.getElementById(id);
        if (m) m.classList.remove('open');
    }

    // Mở modal Thêm mới khách hàng và đặt lại các trường nhập về rỗng
    function openAddKhachHang() {
        const err = document.getElementById('addKhachHangError');
        if (err) err.style.display = 'none';
        document.getElementById('addMaKH').value = '';
        document.getElementById('addHoTen').value = '';
        document.getElementById('addSdt').value = '';
        document.getElementById('addGioiTinh').value = 'Nam';
        document.getElementById('addDiem').value = '0';
        openModalDialog('addKhachHangModal');
    }

    // Mở modal Sửa và điền thông tin khách hàng từ nút bấm
    function openEditKhachHangFromBtn(btn) {
        const err = document.getElementById('editKhachHangError');
        if (err) err.style.display = 'none';

        document.getElementById('editMaKH').value = btn.getAttribute('data-ma') || '';
        document.getElementById('editHoTen').value = btn.getAttribute('data-ten') || '';
        document.getElementById('editSdt').value = btn.getAttribute('data-sdt') || '';
        document.getElementById('editGioiTinh').value = btn.getAttribute('data-gioitinh') || 'Nam';
        document.getElementById('editDiem').value = btn.getAttribute('data-diem') || '0';

        openModalDialog('editKhachHangModal');
    }

    // Mở modal Chi tiết và hiển thị thông tin khách hàng
    function openDetailKhachHangFromBtn(btn) {
        document.getElementById('detailMaKH').innerText = btn.getAttribute('data-ma') || '';
        document.getElementById('detailHoTen').innerText = btn.getAttribute('data-ten') || '';
        document.getElementById('detailSdt').innerText = btn.getAttribute('data-sdt') || '';
        document.getElementById('detailGioiTinh').innerText = btn.getAttribute('data-gioitinh') || '';
        document.getElementById('detailDiem').innerText = (btn.getAttribute('data-diem') || '0') + ' điểm';

        openModalDialog('detailKhachHangModal');
    }

    // Xác nhận với người dùng trước khi tiến hành xóa khách hàng
    function confirmDeleteCustomer(btn) {
        const ma = btn.getAttribute('data-ma');
        const ten = btn.getAttribute('data-ten');
        const ctx = btn.getAttribute('data-context');

        if (confirm('Bạn có chắc chắn muốn xóa khách hàng [' + ma + ' - ' + ten + '] không?')) {
            window.location.href = ctx + '/khach-hang/delete?id=' + encodeURIComponent(ma);
        }
    }

    // Tự động đóng popup khi click ra ngoài vùng nền mờ
    window.addEventListener('click', function(e) {
        if (e.target.classList.contains('modal-backdrop') && e.target.classList.contains('open')) {
            e.target.classList.remove('open');
        }
    });

    // Tự động đóng popup khi người dùng nhấn phím Esc
    window.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-backdrop.open').forEach(function(m) {
                m.classList.remove('open');
            });
        }
    });
</script>
</body>
</html>
