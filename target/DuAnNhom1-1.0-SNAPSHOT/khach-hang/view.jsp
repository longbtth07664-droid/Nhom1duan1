<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lí khách hàng - Rạp Chiếu Phim CINEMAX</title>
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
                    <a href="${pageContext.request.contextPath}/phim/view" class="nav-subitem">Danh sách phim</a>
                    <a href="${pageContext.request.contextPath}/the-loai/view" class="nav-subitem">Quản lí thể loại</a>
                </div>
            </div>

            <div class="nav-group">
                <button type="button" class="nav-item nav-parent" onclick="toggleSubmenu(this)">
                    <span>Phòng ghế</span>
                    <span class="nav-arrow">▾</span>
                </button>
                <div class="nav-submenu">
                    <a href="${pageContext.request.contextPath}/phong-chieu/view" class="nav-subitem">Danh sách phòng chiếu</a>
                </div>
            </div>

            <a href="#" class="nav-item">
                <span>Lịch chiếu bán vé</span>
            </a>

            <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="nav-item">
                <span>Quản lí sản phẩm</span>
            </a>

            <a href="${pageContext.request.contextPath}/quan-ly-combo" class="nav-item">
                <span>Quản lí combo</span>
            </a>

            <a href="${pageContext.request.contextPath}/khach-hang/view" class="nav-item active">
                <span>Quản lí khách hàng</span>
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
            <a href="<%= request.getContextPath() %>/logout" class="role-switch-link" style="color: #ff4757; margin-top: 8px;">Đăng xuất</a>
        </div>
    </aside>

    <!-- NỘI DUNG QUẢN LÍ KHÁCH HÀNG -->
    <div class="main-wrapper">
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Quản lí khách hàng</h2>
                </div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/menuadmin.jsp" class="btn btn-ghost btn-sm">Menu chính</a>
            </div>
        </header>

        <main class="content-area">
            <!-- THÔNG BÁO KẾT QUẢ -->
            <c:if test="${not empty successMsg}">
                <div class="alert-success" style="margin-bottom: 14px; padding: 10px 16px; background:#ecfdf5; color:#065f46; border:1px solid #a7f3d0; border-radius:6px; font-weight:500;">
                    ✓ <c:out value="${successMsg}"/>
                </div>
            </c:if>

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
                                        <button type="button"
                                                class="btn btn-ghost btn-sm"
                                                data-ma="<c:out value='${item.maKH}'/>"
                                                data-ten="<c:out value='${item.hoTen}'/>"
                                                data-sdt="<c:out value='${item.sdt}'/>"
                                                data-gioitinh="<c:out value='${item.gioiTinh}'/>"
                                                data-diem="<c:out value='${item.diemTichLuy}'/>"
                                                onclick="openDetailKhachHangFromBtn(this)">Chi tiết</button>
                                        <button type="button"
                                                class="btn btn-outline btn-sm"
                                                data-ma="<c:out value='${item.maKH}'/>"
                                                data-ten="<c:out value='${item.hoTen}'/>"
                                                data-sdt="<c:out value='${item.sdt}'/>"
                                                data-gioitinh="<c:out value='${item.gioiTinh}'/>"
                                                data-diem="<c:out value='${item.diemTichLuy}'/>"
                                                onclick="openEditKhachHangFromBtn(this)">Sửa</button>
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

                <!-- THANH PHÂN TRANG (5 KHÁCH HÀNG / 1 TRANG) -->
                <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 20px; border-top: 1px solid var(--border-subtle); flex-wrap: wrap; gap: 10px;">
                    <div style="color: var(--text-secondary); font-size: 13px;">
                        Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> (Tổng cộng: <strong>${totalItems}</strong> khách hàng)
                    </div>

                    <div style="display: flex; gap: 6px; align-items: center;">
                        <%-- Nút về trang đầu và trang trước --%>
                        <c:if test="${currentPage > 1}">
                            <a href="${pageContext.request.contextPath}/khach-hang/view?page=1" class="btn btn-ghost btn-sm">&laquo; Đầu</a>
                            <a href="${pageContext.request.contextPath}/khach-hang/view?page=${currentPage - 1}" class="btn btn-ghost btn-sm">&lsaquo; Trước</a>
                        </c:if>

                        <%-- Các số trang 1, 2, 3... --%>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <a href="${pageContext.request.contextPath}/khach-hang/view?page=${p}"
                               class="btn btn-sm ${currentPage == p ? 'btn-pink' : 'btn-ghost'}"
                               style="min-width: 32px; justify-content: center; font-weight: ${currentPage == p ? '700' : '400'};">
                                ${p}
                            </a>
                        </c:forEach>

                        <%-- Nút sang trang sau và trang cuối --%>
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

<!-- POP-UP THÊM KHÁCH HÀNG -->
<div class="modal-backdrop ${openModal == 'add' ? 'open' : ''}" id="addKhachHangModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Thêm khách hàng</h3>
            <button type="button" class="modal-close" onclick="closeModal('addKhachHangModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'add' and not empty error}">
            <div class="alert-error" id="addKhachHangError"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/khach-hang/add" method="post">
            <div class="form-stack">
                <div class="form-group">
                    <label for="addMaKH">Mã khách hàng<span class="required-star">*</span></label>
                    <input type="text" id="addMaKH" name="maKH" class="form-control"
                           value="${openModal == 'add' ? kh.maKH : ''}"
                           placeholder="VD: KH001">
                </div>
                <div class="form-group">
                    <label for="addHoTen">Họ tên<span class="required-star">*</span></label>
                    <input type="text" id="addHoTen" name="hoTen" class="form-control"
                           value="${openModal == 'add' ? kh.hoTen : ''}"
                           placeholder="VD: Nguyễn Văn A">
                </div>
                <div class="form-group">
                    <label for="addSdt">Số điện thoại<span class="required-star">*</span></label>
                    <input type="text" id="addSdt" name="sdt" class="form-control"
                           value="${openModal == 'add' ? kh.sdt : ''}"
                           placeholder="VD: 0901234567">
                </div>
                <div class="form-group">
                    <label for="addGioiTinh">Giới tính</label>
                    <select id="addGioiTinh" name="gioiTinh" class="form-control">
                        <option value="">-- Chọn giới tính --</option>
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
                <div style="font-size:12px; color:var(--text-secondary);">
                    (<span class="required-star">*</span>) Trường bắt buộc nhập
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addKhachHangModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Thêm</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP SỬA KHÁCH HÀNG -->
<div class="modal-backdrop ${openModal == 'update' ? 'open' : ''}" id="editKhachHangModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Sửa thông tin khách hàng</h3>
            <button type="button" class="modal-close" onclick="closeModal('editKhachHangModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'update' and not empty error}">
            <div class="alert-error" id="editKhachHangError"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/khach-hang/update" method="post">
            <div class="form-stack">
                <div class="form-group">
                    <label for="editMaKH">Mã khách hàng</label>
                    <input type="text" id="editMaKH" name="maKH" class="form-control"
                           value="${openModal == 'update' ? kh.maKH : ''}" readonly
                           style="background: var(--bg-input); color: var(--text-secondary);">
                </div>
                <div class="form-group">
                    <label for="editHoTen">Họ tên<span class="required-star">*</span></label>
                    <input type="text" id="editHoTen" name="hoTen" class="form-control"
                           value="${openModal == 'update' ? kh.hoTen : ''}">
                </div>
                <div class="form-group">
                    <label for="editSdt">Số điện thoại<span class="required-star">*</span></label>
                    <input type="text" id="editSdt" name="sdt" class="form-control"
                           value="${openModal == 'update' ? kh.sdt : ''}">
                </div>
                <div class="form-group">
                    <label for="editGioiTinh">Giới tính</label>
                    <select id="editGioiTinh" name="gioiTinh" class="form-control">
                        <option value="">-- Chọn giới tính --</option>
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
                <div style="font-size:12px; color:var(--text-secondary);">
                    (<span class="required-star">*</span>) Trường bắt buộc nhập
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('editKhachHangModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Lưu cập nhật</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP CHI TIẾT KHÁCH HÀNG -->
<div class="modal-backdrop" id="detailKhachHangModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Chi tiết khách hàng</h3>
            <button type="button" class="modal-close" onclick="closeModal('detailKhachHangModal')">&times;</button>
        </div>
        <div class="form-stack">
            <div class="form-group">
                <label>Mã khách hàng</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailMaKH"></div>
            </div>
            <div class="form-group">
                <label>Họ tên</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailHoTen"></div>
            </div>
            <div class="form-group">
                <label>Số điện thoại</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailSdt"></div>
            </div>
            <div class="form-group">
                <label>Giới tính</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailGioiTinh"></div>
            </div>
            <div class="form-group">
                <label>Điểm tích lũy</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailDiem"></div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-pink" onclick="closeModal('detailKhachHangModal')">Đóng</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=5"></script>
<script>
    // Mở modal Thêm - reset form về trống
    function openAddKhachHang() {
        const err = document.getElementById('addKhachHangError');
        if (err) err.style.display = 'none';
        document.getElementById('addMaKH').value = '';
        document.getElementById('addHoTen').value = '';
        document.getElementById('addSdt').value = '';
        document.getElementById('addGioiTinh').value = '';
        document.getElementById('addDiem').value = '0';
        document.getElementById('addKhachHangModal').classList.add('open');
    }

    // Mở modal Sửa - điền dữ liệu từ nút bấm
    function openEditKhachHangFromBtn(btn) {
        const err = document.getElementById('editKhachHangError');
        if (err) err.style.display = 'none';

        document.getElementById('editMaKH').value  = btn.getAttribute('data-ma')       || '';
        document.getElementById('editHoTen').value  = btn.getAttribute('data-ten')      || '';
        document.getElementById('editSdt').value    = btn.getAttribute('data-sdt')      || '';
        document.getElementById('editDiem').value   = btn.getAttribute('data-diem')     || '0';

        // Chọn đúng giới tính trong select
        const gioiTinhVal = btn.getAttribute('data-gioitinh') || '';
        document.getElementById('editGioiTinh').value = gioiTinhVal;

        document.getElementById('editKhachHangModal').classList.add('open');
    }

    // Mở modal Chi tiết - hiển thị thông tin
    function openDetailKhachHangFromBtn(btn) {
        document.getElementById('detailMaKH').textContent    = btn.getAttribute('data-ma')       || '';
        document.getElementById('detailHoTen').textContent   = btn.getAttribute('data-ten')      || '';
        document.getElementById('detailSdt').textContent     = btn.getAttribute('data-sdt')      || '';
        document.getElementById('detailGioiTinh').textContent = btn.getAttribute('data-gioitinh') || '';
        document.getElementById('detailDiem').textContent    = (btn.getAttribute('data-diem') || '0') + ' điểm';
        document.getElementById('detailKhachHangModal').classList.add('open');
    }
</script>
</body>
</html>
