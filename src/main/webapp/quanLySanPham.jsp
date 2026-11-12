<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lí Sản phẩm - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=7">
    <style>
        .alert-success {
            background: #ECFDF5; border: 1px solid #A7F3D0; color: #047857;
            padding: 10px 14px; border-radius: var(--radius-sm);
            font-size: 13px; font-weight: 600; margin-bottom: 16px;
        }
        .badge-success {
            display: inline-block; padding: 4px 10px; border-radius: 99px;
            font-size: 11px; font-weight: 700; background: #ECFDF5; color: #047857;
        }
        .badge-danger {
            display: inline-block; padding: 4px 10px; border-radius: 99px;
            font-size: 11px; font-weight: 700; background: #FEF2F2; color: #DC2626;
        }
        .filter-bar {
            display: flex; flex-wrap: wrap; gap: 10px; align-items: center; margin-bottom: 16px;
        }
    </style>
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

            <a href="#" class="nav-item">
                <span>Phòng ghế</span>
            </a>

            <a href="#" class="nav-item">
                <span>Lịch chiếu bán vé</span>
            </a>

            <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="nav-item active">
                <span>Quản lí sản phẩm</span>
            </a>

            <a href="${pageContext.request.contextPath}/quan-ly-combo" class="nav-item">
                <span>Quản lí combo</span>
            </a>
        </nav>

        <div class="sidebar-footer">
            <div class="user-card">
                <div class="user-avatar">QL</div>
                <div class="user-info">
                    <div class="name"><c:out value="${not empty sessionScope.userName ? sessionScope.userName : 'Quản lý rạp'}"/></div>
                    <div class="role"><c:out value="${not empty sessionScope.userRole ? sessionScope.userRole : 'QuanLy'}"/></div>
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
                    <h2>Quản lí sản phẩm (Bắp - Nước - Snack)</h2>
                </div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/quan-ly-combo" class="btn btn-outline btn-sm">Sang Quản lí combo</a>
            </div>
        </header>

        <main class="content-area">

            <c:if test="${param.msg == 'add_ok'}">
                <div class="alert-success">Thêm sản phẩm thành công! Bạn đã có thể chọn sản phẩm này trong mục Thêm Combo.</div>
            </c:if>
            <c:if test="${param.msg == 'update_ok'}">
                <div class="alert-success">Cập nhật sản phẩm thành công!</div>
            </c:if>
            <c:if test="${param.msg == 'delete_ok'}">
                <div class="alert-success">Đã xóa sản phẩm thành công!</div>
            </c:if>
            <c:if test="${param.msg == 'delete_fail'}">
                <div class="alert-error">Không thể xóa! Sản phẩm đang nằm trong Combo hoặc Hóa đơn (hãy chuyển sang Ngừng kinh doanh).</div>
            </c:if>
            <c:if test="${param.msg == 'duplicate_id'}">
                <div class="alert-error">Mã sản phẩm đã tồn tại!</div>
            </c:if>
            <c:if test="${param.msg == 'invalid_data' || param.msg == 'error'}">
                <div class="alert-error">Dữ liệu không hợp lệ hoặc thao tác thất bại!</div>
            </c:if>

            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Danh sách sản phẩm</div>
                        <div class="card-subtitle">Các sản phẩm đang kinh doanh sẽ tự hiển thị để chọn khi tạo Combo</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <a href="${pageContext.request.contextPath}/quan-ly-combo" class="btn btn-outline">Quản lí combo</a>
                        <button type="button" class="btn btn-pink" onclick="openModal('addSPModal')">+ Thêm sản phẩm</button>
                        <span class="badge-pink">${dsSanPham.size()} sản phẩm</span>
                    </div>
                </div>

                <%-- Tìm kiếm & lọc --%>
                <form action="${pageContext.request.contextPath}/quan-ly-san-pham" method="get" class="filter-bar">
                    <input type="hidden" name="action" value="search">
                    <input type="text" name="keyword" class="form-control" style="max-width: 280px;"
                           placeholder="Tìm theo mã, tên hoặc loại SP..." value="<c:out value='${keyword}'/>">
                    <select name="trangThai" class="form-control" style="max-width: 200px;">
                        <option value="Tất cả">Tất cả trạng thái</option>
                        <option value="Đang kinh doanh" ${trangThaiLoc == 'Đang kinh doanh' ? 'selected' : ''}>Đang kinh doanh</option>
                        <option value="Ngừng kinh doanh" ${trangThaiLoc == 'Ngừng kinh doanh' ? 'selected' : ''}>Ngừng kinh doanh</option>
                    </select>
                    <button type="submit" class="btn btn-outline">Tìm kiếm</button>
                    <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="btn btn-ghost">Làm mới</a>
                </form>

                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>STT</th>
                            <th>Mã SP</th>
                            <th>Tên Sản Phẩm</th>
                            <th>Loại SP</th>
                            <th>Đơn Vị</th>
                            <th>Giá Bán</th>
                            <th>Tồn Kho</th>
                            <th>Trạng Thái</th>
                            <th>Hành Động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${dsSanPham}" var="sp" varStatus="st">
                            <tr>
                                <td>${st.index + 1}</td>
                                <td><strong><c:out value="${sp.maSP}"/></strong></td>
                                <td><c:out value="${sp.tenSP}"/></td>
                                <td><c:out value="${sp.loaiSP}"/></td>
                                <td><c:out value="${sp.donViTinh}"/></td>
                                <td><strong><fmt:formatNumber value="${sp.giaBan}" pattern="#,###"/> đ</strong></td>
                                <td>${sp.soLuongTon}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${sp.trangThai == 'Đang kinh doanh'}">
                                            <span class="badge-success">Đang kinh doanh</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-danger"><c:out value="${sp.trangThai}"/></span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="action-group">
                                        <a href="${pageContext.request.contextPath}/quan-ly-san-pham?action=edit&id=${sp.maSP}"
                                           class="btn btn-outline btn-sm">Sửa</a>
                                        <button type="button" class="btn btn-outline btn-sm"
                                                style="color:#DC2626; border-color:#FECACA;"
                                                data-ma="<c:out value='${sp.maSP}'/>"
                                                data-ten="<c:out value='${sp.tenSP}'/>"
                                                onclick="xoaSP(this)">Xóa</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty dsSanPham}">
                            <tr>
                                <td colspan="9" style="text-align:center; color:var(--text-secondary);">Không có sản phẩm nào.</td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- POP-UP THÊM SẢN PHẨM -->
<div class="modal-backdrop" id="addSPModal">
    <div class="modal-box" style="max-width:560px;">
        <div class="modal-header">
            <h3>Thêm sản phẩm mới</h3>
            <button type="button" class="modal-close" onclick="closeModal('addSPModal')">&times;</button>
        </div>

        <form action="${pageContext.request.contextPath}/quan-ly-san-pham" method="post">
            <input type="hidden" name="action" value="add">
            <div class="form-grid">
                <div class="form-group">
                    <label>Mã sản phẩm<span class="required-star">*</span></label>
                    <input type="text" name="maSP" class="form-control" value="${newId}" readonly>
                </div>
                <div class="form-group">
                    <label>Tên sản phẩm<span class="required-star">*</span></label>
                    <input type="text" name="tenSP" class="form-control" placeholder="VD: Bắp Caramel (Vừa)" required>
                </div>
                <div class="form-group">
                    <label>Loại sản phẩm<span class="required-star">*</span></label>
                    <select name="loaiSP" class="form-control" required>
                        <option value="Bắp">Bắp</option>
                        <option value="Nước có gas">Nước có gas</option>
                        <option value="Nước suối">Nước suối</option>
                        <option value="Snack">Snack</option>
                        <option value="Đồ ăn nóng">Đồ ăn nóng</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Đơn vị tính<span class="required-star">*</span></label>
                    <select name="donViTinh" class="form-control" required>
                        <option value="Hộp">Hộp</option>
                        <option value="Ly">Ly</option>
                        <option value="Chai">Chai</option>
                        <option value="Gói">Gói</option>
                        <option value="Cây">Cây</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Giá bán (VNĐ)<span class="required-star">*</span></label>
                    <input type="number" name="giaBan" class="form-control" min="1000" placeholder="VD: 45000" required>
                </div>
                <div class="form-group">
                    <label>Số lượng tồn<span class="required-star">*</span></label>
                    <input type="number" name="soLuongTon" class="form-control" min="0" value="100" required>
                </div>
            </div>
            <div class="form-group" style="margin-bottom:14px;">
                <label>Trạng thái</label>
                <select name="trangThai" class="form-control">
                    <option value="Đang kinh doanh" selected>Đang kinh doanh</option>
                    <option value="Ngừng kinh doanh">Ngừng kinh doanh</option>
                </select>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addSPModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Lưu sản phẩm</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP SỬA SẢN PHẨM -->
<c:if test="${editSP != null}">
    <div class="modal-backdrop open" id="editSPModal">
        <div class="modal-box" style="max-width:560px;">
            <div class="modal-header">
                <h3>Sửa sản phẩm: <c:out value="${editSP.maSP}"/></h3>
                <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="modal-close">&times;</a>
            </div>

            <form action="${pageContext.request.contextPath}/quan-ly-san-pham" method="post">
                <input type="hidden" name="action" value="update">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Mã sản phẩm</label>
                        <input type="text" name="maSP" class="form-control" value="<c:out value='${editSP.maSP}'/>" readonly>
                    </div>
                    <div class="form-group">
                        <label>Tên sản phẩm<span class="required-star">*</span></label>
                        <input type="text" name="tenSP" class="form-control" value="<c:out value='${editSP.tenSP}'/>" required>
                    </div>
                    <div class="form-group">
                        <label>Loại sản phẩm<span class="required-star">*</span></label>
                        <select name="loaiSP" class="form-control" required>
                            <option value="Bắp" ${editSP.loaiSP == 'Bắp' ? 'selected' : ''}>Bắp</option>
                            <option value="Nước có gas" ${editSP.loaiSP == 'Nước có gas' ? 'selected' : ''}>Nước có gas</option>
                            <option value="Nước suối" ${editSP.loaiSP == 'Nước suối' ? 'selected' : ''}>Nước suối</option>
                            <option value="Snack" ${editSP.loaiSP == 'Snack' ? 'selected' : ''}>Snack</option>
                            <option value="Đồ ăn nóng" ${editSP.loaiSP == 'Đồ ăn nóng' ? 'selected' : ''}>Đồ ăn nóng</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Đơn vị tính<span class="required-star">*</span></label>
                        <select name="donViTinh" class="form-control" required>
                            <option value="Hộp" ${editSP.donViTinh == 'Hộp' ? 'selected' : ''}>Hộp</option>
                            <option value="Ly" ${editSP.donViTinh == 'Ly' ? 'selected' : ''}>Ly</option>
                            <option value="Chai" ${editSP.donViTinh == 'Chai' ? 'selected' : ''}>Chai</option>
                            <option value="Gói" ${editSP.donViTinh == 'Gói' ? 'selected' : ''}>Gói</option>
                            <option value="Cây" ${editSP.donViTinh == 'Cây' ? 'selected' : ''}>Cây</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Giá bán (VNĐ)<span class="required-star">*</span></label>
                        <input type="number" name="giaBan" class="form-control" value="${editSP.giaBan}" min="1000" required>
                    </div>
                    <div class="form-group">
                        <label>Số lượng tồn<span class="required-star">*</span></label>
                        <input type="number" name="soLuongTon" class="form-control" value="${editSP.soLuongTon}" min="0" required>
                    </div>
                </div>
                <div class="form-group" style="margin-bottom:14px;">
                    <label>Trạng thái</label>
                    <select name="trangThai" class="form-control">
                        <option value="Đang kinh doanh" ${editSP.trangThai == 'Đang kinh doanh' ? 'selected' : ''}>Đang kinh doanh</option>
                        <option value="Ngừng kinh doanh" ${editSP.trangThai == 'Ngừng kinh doanh' ? 'selected' : ''}>Ngừng kinh doanh</option>
                    </select>
                </div>
                <div class="modal-footer">
                    <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="btn btn-ghost">Hủy</a>
                    <button type="submit" class="btn btn-pink">Lưu cập nhật</button>
                </div>
            </form>
        </div>
    </div>
</c:if>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=5"></script>
<script>
    function xoaSP(btn) {
        var ma = btn.getAttribute('data-ma');
        var ten = btn.getAttribute('data-ten');
        if (confirm('Bạn có chắc muốn xóa sản phẩm "' + ten + '" (' + ma + ') không?')) {
            window.location.href = '${pageContext.request.contextPath}/quan-ly-san-pham?action=delete&id=' + encodeURIComponent(ma);
        }
    }
</script>
</body>
</html>