<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="/WEB-INF/tld/c.tld" %>
<%@ taglib prefix="fmt" uri="/WEB-INF/tld/fmt.tld" %>
<%@ taglib prefix="fn" uri="/WEB-INF/tld/fn.tld" %>
<%-- Dùng đường dẫn TLD cụ thể để IDE và Tomcat cùng nhận diện thư viện thẻ. --%>
<%-- Truy cập JSP trực tiếp phải đi qua controller để có dữ liệu và kiểm tra quyền. --%>
<c:if test="${empty requestScope.dsCombo}"><c:if test="${requestScope.dsCombo == null}"><c:redirect url="/quan-ly-combo"/></c:if></c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lí Combo - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=7">
    <style>
        /* --- Style riêng cho module Combo --- */
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
        .modal-box-lg { max-width: 780px; max-height: 90vh; overflow-y: auto; }
        .filter-bar { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; margin-bottom: 16px; }
        .combo-detail-box { margin-top: 14px; padding-top: 14px; border-top: 1px solid var(--border-subtle); }

        /* Ô hiển thị ảnh combo — nếu chưa có file .jpg thì hiện placeholder chứa tên file */
        .combo-thumb {
            width: 56px; height: 56px; object-fit: cover;
            border-radius: 8px; border: 1px solid var(--border-subtle);
            display: block; background: var(--bg-input);
        }
        .combo-thumb-placeholder {
            width: 56px; height: 56px; border-radius: 8px;
            border: 1px dashed var(--border-strong); background: var(--bg-input);
            display: none; align-items: center; justify-content: center;
            font-size: 10px; font-weight: 700; color: var(--text-secondary);
            text-align: center; padding: 4px; word-break: break-all;
        }

        /* Bảng tích chọn sản phẩm trong modal Thêm/Sửa */
        .sp-picker-wrap {
            max-height: 250px; overflow-y: auto;
            border: 1px solid var(--border-subtle); border-radius: var(--radius-sm); margin-top: 8px;
        }
        .sp-row-active { background: var(--pink-soft); } /* Highlight hàng khi được tích */
        .tong-gia-le {
            margin-top: 10px; font-size: 13px; font-weight: 700; color: var(--pink); text-align: right;
        }
    </style>
</head>
<body>
<div class="app-shell">

    <%-- ==================== SIDEBAR MENU ==================== --%>
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            <div class="brand-text">
                <h1>Rạp Chiếu Phim CINEMAX</h1>
                <span>Quản lý</span>
            </div>
        </div>

        <nav class="sidebar-menu">
            <div class="menu-group-label">Menu chức năng</div>

            <a href="#" class="nav-item"><span>Tổng quan</span></a>

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

            <a href="${pageContext.request.contextPath}/phong-chieu/view" class="nav-item"><span>Phòng ghế</span></a>
            <a href="#" class="nav-item"><span>Lịch chiếu bán vé</span></a>
            <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="nav-item"><span>Quản lí sản phẩm</span></a>
            <a href="${pageContext.request.contextPath}/quan-ly-combo" class="nav-item active"><span>Quản lí combo</span></a>
        </nav>

        <%-- Thông tin tài khoản & nút đăng xuất --%>
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
    <%-- ==================== NỘI DUNG CHÍNH ==================== --%>
    <div class="main-wrapper">

        <%-- Header trên cùng --%>
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap"><h2>Quản lí combo bắp nước</h2></div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/menuadmin.jsp" class="btn btn-ghost btn-sm">Menu chính</a>
            </div>
        </header>

        <main class="content-area">
            <%-- COMBO: thông báo cụ thể được escape trước khi hiển thị. --%>
            <c:if test="${not empty param.error}"><div class="alert-error"><c:out value="${param.error}"/></div></c:if>

            <%-- === Thông báo phản hồi sau khi Thêm/Sửa/Xóa === --%>
            <c:if test="${param.msg == 'add_ok'}">
                <div class="alert-success">Thêm combo mới thành công!</div>
            </c:if>
            <c:if test="${param.msg == 'update_ok'}">
                <div class="alert-success">Cập nhật thông tin combo thành công!</div>
            </c:if>
            <c:if test="${param.msg == 'delete_ok'}">
                <div class="alert-success">Đã xóa combo thành công!</div>
            </c:if>
            <c:if test="${param.msg == 'delete_fail'}">
                <div class="alert-error">Không thể xóa! Combo này đã được sử dụng trong hóa đơn.</div>
            </c:if>
            <c:if test="${param.msg == 'empty_products'}">
                <div class="alert-error">Vui lòng tích chọn ít nhất 1 sản phẩm bên trong combo!</div>
            </c:if>
            <c:if test="${param.msg == 'duplicate_id'}">
                <div class="alert-error">Mã combo đã tồn tại trong hệ thống!</div>
            </c:if>
            <c:if test="${param.msg == 'invalid_data' || param.msg == 'error'}">
                <div class="alert-error">Dữ liệu không hợp lệ hoặc thao tác thất bại!</div>
            </c:if>

            <div class="card">

                <%-- Header bảng danh sách: tiêu đề + các nút thao tác nhanh --%>
                <div class="card-header">
                    <div>
                        <div class="card-title">Danh sách combo</div>
                        <div class="card-subtitle">Thư mục lưu ảnh: assets/images/combo/ (định dạng .jpg)</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
                        <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="btn btn-outline">Quản lí sản phẩm</a>
                        <button type="button" class="btn btn-pink" onclick="openModal('addComboModal')">+ Thêm combo</button>
                        <span class="badge-pink">${fn:length(dsCombo)} combo</span>
                    </div>
                </div>

                <%-- Thanh tìm kiếm & lọc theo trạng thái bán --%>
                <form action="${pageContext.request.contextPath}/quan-ly-combo" method="get" class="filter-bar">
                    <input type="hidden" name="action" value="search">
                    <input type="text" name="keyword" class="form-control" style="max-width: 280px;"
                           placeholder="Tìm theo mã hoặc tên combo..." value="<c:out value='${keyword}'/>">
                    <select name="trangThai" class="form-control" style="max-width: 180px;">
                        <option value="Tất cả">Tất cả trạng thái</option>
                        <option value="Đang bán" ${trangThaiLoc == 'Đang bán' ? 'selected' : ''}>Đang bán</option>
                        <option value="Ngừng bán" ${trangThaiLoc == 'Ngừng bán' ? 'selected' : ''}>Ngừng bán</option>
                    </select>
                    <button type="submit" class="btn btn-outline">Tìm kiếm</button>
                    <a href="${pageContext.request.contextPath}/quan-ly-combo" class="btn btn-ghost">Làm mới</a>
                </form>

                <%-- Bảng danh sách combo --%>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>STT</th>
                            <th>Hình Ảnh</th>
                            <th>Mã Combo</th>
                            <th>Tên Combo</th>
                            <th>Giá Combo</th>
                            <th>Mô Tả</th>
                            <th>Trạng Thái</th>
                            <th>Hành Động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${dsCombo}" var="cb" varStatus="st">
                            <tr>
                                <td>${st.index + 1}</td>

                                <%-- Tải ảnh an toàn: ưu tiên cb.hinhAnh, nếu trống thì ghép [maCombo].jpg --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty cb.hinhAnh}">
                                            <c:set var="imgName" value="${cb.hinhAnh}"/>
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="imgName" value="${cb.maCombo}.jpg"/>
                                        </c:otherwise>
                                    </c:choose>
                                    <img class="combo-thumb"
                                         src="${pageContext.request.contextPath}/assets/images/combo/${fn:escapeXml(imgName)}"
                                         alt="${fn:escapeXml(cb.tenCombo)}"
                                         onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                    <div class="combo-thumb-placeholder" title="Chưa có file ảnh: ${fn:escapeXml(imgName)}">
                                        <c:out value="${fn:escapeXml(imgName)}"/>
                                    </div>
                                </td>

                                <td><strong><c:out value="${cb.maCombo}"/></strong></td>
                                <td><c:out value="${cb.tenCombo}"/></td>
                                <td><strong><fmt:formatNumber value="${cb.giaCombo}" pattern="#,###"/> đ</strong></td>
                                <td><c:out value="${cb.moTa}"/></td>

                                <%-- Nhãn trạng thái kinh doanh --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${cb.trangThai == 'Đang bán'}">
                                            <span class="badge-success">Đang bán</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-danger"><c:out value="${cb.trangThai}"/></span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Các nút thao tác --%>
                                <td>
                                    <div class="action-group">
                                        <button type="button" class="btn btn-ghost btn-sm"
                                                data-ma="<c:out value='${cb.maCombo}'/>"
                                                data-ten="<c:out value='${cb.tenCombo}'/>"
                                                data-gia="<fmt:formatNumber value='${cb.giaCombo}' pattern='#,###'/> đ"
                                                data-mota="<c:out value='${cb.moTa}'/>"
                                                data-anh="<c:out value='${imgName}'/>"
                                                data-trangthai="<c:out value='${cb.trangThai}'/>"
                                                onclick="xemChiTietCombo(this)">Chi tiết</button>
                                        <a href="${pageContext.request.contextPath}/quan-ly-combo?action=edit&id=${cb.maCombo}"
                                           class="btn btn-outline btn-sm">Sửa</a>
                                        <button type="button" class="btn btn-outline btn-sm"
                                                style="color:#DC2626; border-color:#FECACA;"
                                                data-ma="<c:out value='${cb.maCombo}'/>"
                                                data-ten="<c:out value='${cb.tenCombo}'/>"
                                                onclick="xoaCombo(this)">Xóa</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>

                        <%-- Hiển thị thông báo nếu không có dòng nào --%>
                        <c:if test="${empty dsCombo}">
                            <tr>
                                <td colspan="8" style="text-align:center; color:var(--text-secondary);">Không tìm thấy combo nào.</td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<%-- ==================== MODAL: THÊM COMBO MỚI ==================== --%>
<div class="modal-backdrop" id="addComboModal">
    <div class="modal-box modal-box-lg">
        <div class="modal-header">
            <h3>Thêm combo mới</h3>
            <button type="button" class="modal-close" onclick="closeModal('addComboModal')">&times;</button>
        </div>

        <form action="${pageContext.request.contextPath}/quan-ly-combo" method="post" onsubmit="return validateComboForm('add')">
            <input type="hidden" name="token" value="${sessionScope.comboToken}">
            <input type="hidden" name="action" value="add">

            <%-- Nhập thông tin chung --%>
            <div class="form-grid">
                <div class="form-group">
                    <label>Mã combo<span class="required-star">*</span></label>
                    <input type="text" name="maCombo" class="form-control" value="<c:out value='${newId}'/>" readonly>
                </div>
                <div class="form-group">
                    <label>Tên combo<span class="required-star">*</span></label>
                    <input type="text" name="tenCombo" class="form-control" placeholder="VD: Combo Couple" required>
                </div>
                <div class="form-group">
                    <label>Giá combo (VNĐ)<span class="required-star">*</span></label>
                    <input type="number" name="giaCombo" id="addGiaCombo" class="form-control" value="0" readonly>
                </div>
                <div class="form-group">
                    <label>Trạng thái</label>
                    <%-- Thêm mới luôn đang bán; server cũng áp dụng quy tắc này. --%>
                    <input class="form-control" value="Đang bán" readonly>
                </div>
                <div class="form-group">
                    <label>Tên file hình ảnh (.jpg)</label>
                    <c:set var="defaultNewImg" value="${not empty newId ? fn:toLowerCase(newId) : 'cb01'}"/>
                    <input type="text" name="hinhAnh" class="form-control" value="${defaultNewImg}.jpg" placeholder="VD: combo_couple.jpg">
                </div>
                <div class="form-group">
                    <label>Mô tả</label>
                    <input type="text" name="moTa" class="form-control" placeholder="VD: 1 Bắp lớn + 2 Nước ngọt">
                </div>
            </div>

            <%-- Bảng tích chọn sản phẩm đưa vào combo --%>
            <%-- COMBO: mức giảm tính trên tổng giá lẻ, làm tròn đến đồng. --%><div class="form-group"><label>Mức giảm giá</label><select name="giamGia" id="addGiamGia" class="form-control" onchange="tinhTongGiaLe('add')"><option value="0">Không giảm</option><option value="10">Giảm 10%</option><option value="20">Giảm 20%</option><option value="50">Giảm 50%</option></select></div>
<div class="combo-detail-box">
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <strong style="font-size:13px;">Tích chọn sản phẩm đưa vào combo<span class="required-star">*</span></strong>
                    <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="btn btn-ghost btn-sm">+ Thêm sản phẩm mới</a>
                </div>

                <input type="search" class="form-control" placeholder="Tìm mã hoặc tên sản phẩm..." aria-label="Tìm sản phẩm" oninput="locSanPham('add', this.value)">
<p id="addSearchEmpty" hidden>Không tìm thấy sản phẩm phù hợp.</p>
<div class="sp-picker-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th style="width:50px;">Chọn</th>
                            <th>Sản phẩm</th>
                            <th>Giá lẻ</th>
                            <th style="width:85px;">SL</th>
                            <th>Ghi chú</th>
                        </tr>
                        </thead>
                        <tbody id="addPickerBody">
                        <c:forEach items="${dsSanPham}" var="sp">
                            <tr>
                                <%-- Checkbox chọn sản phẩm lẻ --%>
                                <td style="text-align:center;">
                                    <input type="checkbox" name="ctMaSP" value="${sp.maSP}"
                                           data-gia="${sp.giaBan}" data-stock="${sp.soLuongTon}" data-active="${sp.trangThai == 'Đang kinh doanh'}"
                                           ${sp.soLuongTon <= 0 ? 'disabled' : ''} onchange="toggleProductRow(this, 'add')">
                                </td>
                                <td>
                                    <strong><c:out value="${sp.tenSP}"/></strong><br>
                                    <span style="font-size:11px; color:var(--text-secondary);"><c:out value="${sp.maSP}"/> - <c:out value="${sp.donViTinh}"/> · Tồn: ${sp.soLuongTon} · <c:out value="${sp.trangThai}"/></span>
                                </td>
                                <td><fmt:formatNumber value="${sp.giaBan}" pattern="#,###"/> đ</td>
                                <%-- Ô nhập số lượng, tự bật khi tích chọn --%>
                                <td>
                                    <input type="number" name="ctSoLuong_${sp.maSP}" value="1" min="1" max="${sp.soLuongTon}" required
                                           class="form-control" style="padding:6px 8px;" disabled
                                           onchange="tinhTongGiaLe('add')" oninput="tinhTongGiaLe('add')">
                                </td>
                                <td>
                                    <input type="text" maxlength="100" name="ctGhiChu_${sp.maSP}" placeholder="Ghi chú..."
                                           class="form-control" style="padding:6px 8px;" disabled>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
                <%-- Tính nhẩm tổng giá lẻ các món đang chọn --%>
                <div class="tong-gia-le" id="addTongGiaLe">Tổng giá lẻ các món đã chọn: 0 đ</div>
            </div>

            <div class="modal-footer" style="margin-top:16px;">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addComboModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Lưu combo</button>
            </div>
        </form>
    </div>
</div>

<%-- ==================== MODAL: SỬA COMBO ==================== --%>
<c:if test="${editCombo != null}">
    <div class="modal-backdrop open" id="editComboModal">
        <div class="modal-box modal-box-lg">
            <div class="modal-header">
                <h3>Sửa combo: <c:out value="${editCombo.maCombo}"/></h3>
                <a href="${pageContext.request.contextPath}/quan-ly-combo" class="modal-close">&times;</a>
            </div>

            <form action="${pageContext.request.contextPath}/quan-ly-combo" method="post" onsubmit="return validateComboForm('edit')">
                <input type="hidden" name="token" value="${sessionScope.comboToken}">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="version" value="${version}">

                <%-- Nhập thông tin chỉnh sửa combo --%>
                <div class="form-grid">
                    <div class="form-group">
                        <label>Mã combo</label>
                        <input type="text" name="maCombo" class="form-control" value="<c:out value='${editCombo.maCombo}'/>" readonly>
                    </div>
                    <div class="form-group">
                        <label>Tên combo<span class="required-star">*</span></label>
                        <input type="text" name="tenCombo" class="form-control" value="<c:out value='${editCombo.tenCombo}'/>" required>
                    </div>
                    <div class="form-group">
                        <label>Giá combo (VNĐ)<span class="required-star">*</span></label>
                        <input type="number" name="giaCombo" id="editGiaCombo" data-original="${editCombo.giaCombo}" class="form-control" value="${editCombo.giaCombo}" readonly>
                    </div>
                    <div class="form-group">
                        <label>Trạng thái</label>
                        <select name="trangThai" class="form-control">
                            <option value="Đang bán" ${editCombo.trangThai == 'Đang bán' ? 'selected' : ''}>Đang bán</option>
                            <option value="Ngừng bán" ${editCombo.trangThai == 'Ngừng bán' ? 'selected' : ''}>Ngừng bán</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Tên file hình ảnh (.jpg)</label>
                        <input type="text" name="hinhAnh" class="form-control" value="<c:out value='${editCombo.hinhAnh}'/>" placeholder="VD: combo_couple.jpg">
                    </div>
                    <div class="form-group">
                        <label>Mô tả</label>
                        <input type="text" name="moTa" class="form-control" value="<c:out value='${editCombo.moTa}'/>">
                    </div>
                </div>

                <%-- Bảng sản phẩm trong combo đang sửa (tự tích sẵn các món đã có) --%>
                <%-- COMBO: mức giảm tính trên tổng giá lẻ, làm tròn đến đồng. --%><div class="form-group"><label>Mức giảm giá</label><select name="giamGia" id="editGiamGia" class="form-control" onchange="tinhTongGiaLe('edit')"><option value="-1">Giữ giá đã lưu</option><option value="0">Không giảm</option><option value="10">Giảm 10%</option><option value="20">Giảm 20%</option><option value="50">Giảm 50%</option></select></div>
<div class="combo-detail-box">
                    <strong style="font-size:13px;">Tích chọn sản phẩm bên trong combo<span class="required-star">*</span></strong>
                    <input type="search" class="form-control" placeholder="Tìm mã hoặc tên sản phẩm..." aria-label="Tìm sản phẩm" oninput="locSanPham('edit', this.value)">
<p id="editSearchEmpty" hidden>Không tìm thấy sản phẩm phù hợp.</p>
<div class="sp-picker-wrap">
                        <table>
                            <thead>
                            <tr>
                                <th style="width:50px;">Chọn</th>
                                <th>Sản phẩm</th>
                                <th>Giá lẻ</th>
                                <th style="width:85px;">SL</th>
                                <th>Ghi chú</th>
                            </tr>
                            </thead>
                            <tbody id="editPickerBody">
                            <c:forEach items="${dsSanPhamSua}" var="sp">
                                <c:set var="ctItem" value="${editChiTietMap[sp.maSP]}"/>
                                <c:set var="isChecked" value="${ctItem != null}"/>
                                <tr class="${isChecked ? 'sp-row-active' : ''}">
                                    <td style="text-align:center;">
                                        <input type="checkbox" name="ctMaSP" value="${sp.maSP}"
                                               data-gia="${sp.giaBan}" data-stock="${sp.soLuongTon}" data-active="${sp.trangThai == 'Đang kinh doanh'}"
                                               ${isChecked ? 'checked' : ''} ${!isChecked && (sp.soLuongTon <= 0 || sp.trangThai != 'Đang kinh doanh') ? 'disabled' : ''}
                                               onchange="toggleProductRow(this, 'edit')">
                                    </td>
                                    <td>
                                        <strong><c:out value="${sp.tenSP}"/></strong><br>
                                        <span style="font-size:11px; color:var(--text-secondary);"><c:out value="${sp.maSP}"/> - <c:out value="${sp.donViTinh}"/> · Tồn: ${sp.soLuongTon} · <c:out value="${sp.trangThai}"/></span>
                                    </td>
                                    <td><fmt:formatNumber value="${sp.giaBan}" pattern="#,###"/> đ</td>
                                    <td>
                                        <input type="number" name="ctSoLuong_${sp.maSP}"
                                               value="${isChecked ? ctItem.soLuong : 1}" min="1" max="${sp.soLuongTon}" required
                                               class="form-control" style="padding:6px 8px;"
                                               ${isChecked ? '' : 'disabled'}
                                               onchange="tinhTongGiaLe('edit')" oninput="tinhTongGiaLe('edit')">
                                    </td>
                                    <td>
                                        <c:set var="oldGhiChu" value="${isChecked ? ctItem.ghiChu : ''}"/>
                                        <input type="text" maxlength="100" name="ctGhiChu_${sp.maSP}"
                                               value="<c:out value='${oldGhiChu}'/>"
                                               placeholder="Ghi chú..."
                                               class="form-control" style="padding:6px 8px;"
                                               ${isChecked ? '' : 'disabled'}>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <div class="tong-gia-le" id="editTongGiaLe">Tổng giá lẻ các món đã chọn: 0 đ</div>
                </div>

                <div class="modal-footer" style="margin-top:16px;">
                    <a href="${pageContext.request.contextPath}/quan-ly-combo" class="btn btn-ghost">Hủy</a>
                    <button type="submit" class="btn btn-pink">Lưu cập nhật</button>
                </div>
            </form>
        </div>
    </div>
</c:if>

<%-- ==================== MODAL: XEM CHI TIẾT COMBO ==================== --%>
<div class="modal-backdrop" id="detailComboModal">
    <div class="modal-box modal-box-lg">
        <div class="modal-header">
            <h3>Chi tiết combo</h3>
            <button type="button" class="modal-close" onclick="closeModal('detailComboModal')">&times;</button>
        </div>

        <%-- Thông tin cơ bản combo (gán qua Javascript) --%>
        <div class="form-grid">
            <div class="form-group">
                <label>Mã combo</label>
                <div class="form-control" style="background:var(--bg-input);" id="dtMaCombo"></div>
            </div>
            <div class="form-group">
                <label>Tên combo</label>
                <div class="form-control" style="background:var(--bg-input);" id="dtTenCombo"></div>
            </div>
            <div class="form-group">
                <label>Giá combo</label>
                <div class="form-control" style="background:var(--bg-input);" id="dtGiaCombo"></div>
            </div>
            <div class="form-group">
                <label>File hình ảnh (.jpg)</label>
                <div class="form-control" style="background:var(--bg-input);" id="dtHinhAnh"></div>
            </div>
        </div>
        <div class="form-group" style="margin-bottom:14px;">
            <label>Mô tả</label>
            <div class="form-control" style="background:var(--bg-input);" id="dtMoTa"></div>
        </div>

        <%-- Bảng hiển thị danh sách món bên trong combo tải qua AJAX --%>
        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>Mã SP</th>
                    <th>Tên Sản Phẩm</th>
                    <th>Đơn Vị</th>
                    <th>Số Lượng</th>
                    <th>Giá Bán Lẻ</th>
                    <th>Ghi Chú</th>
                </tr>
                </thead>
                <tbody id="detailComboBody"></tbody>
            </table>
        </div>

        <div class="modal-footer" style="margin-top:16px;">
            <button type="button" class="btn btn-pink" onclick="closeModal('detailComboModal')">Đóng</button>
        </div>
    </div>
</div>

<%-- ==================== JAVASCRIPT XỬ LÝ GIAO DIỆN ==================== --%>
<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=5"></script>
<script>
    // Bật/tắt ô SL và Ghi chú khi tích chọn sản phẩm
    function toggleProductRow(checkbox, mode) {
        var row = checkbox.closest('tr');
        var inputs = row.querySelectorAll('input[type="number"], input[type="text"]');
        for (var i = 0; i < inputs.length; i++) {
            inputs[i].disabled = !checkbox.checked;
        }
        row.classList.toggle('sp-row-active', checkbox.checked);
        tinhTongGiaLe(mode);
    }

    // Mở modal Chi tiết qua AJAX Fetch
    var detailRequest = 0; // Bỏ phản hồi cũ nếu người dùng đã chuyển sang combo khác.
    function xemChiTietCombo(btn) {
        var requestId = ++detailRequest;
        var ma = btn.getAttribute('data-ma') || '';
        document.getElementById('dtMaCombo').textContent = ma;
        document.getElementById('dtTenCombo').textContent = btn.getAttribute('data-ten') || '';
        document.getElementById('dtGiaCombo').textContent = btn.getAttribute('data-gia') || '';
        document.getElementById('dtHinhAnh').textContent = btn.getAttribute('data-anh') || '';
        document.getElementById('dtMoTa').textContent = btn.getAttribute('data-mota') || '';

        var tbody = document.getElementById('detailComboBody');
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;">Đang tải dữ liệu...</td></tr>';
        openModal('detailComboModal');

        fetch('${pageContext.request.contextPath}/quan-ly-combo?action=chiTiet&id=' + encodeURIComponent(ma))
            .then(function (res) {
                // HTTP lỗi phải đi vào nhánh thông báo thất bại.
                if (!res.ok) throw new Error('Không tải được chi tiết combo');
                return res.json();
            })
            .then(function (data) {
                if (requestId !== detailRequest) return;
                tbody.innerHTML = '';
                if (data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:var(--text-secondary);">Chưa có sản phẩm nào trong combo này.</td></tr>';
                    return;
                }
                data.forEach(function (ct) {
                    var tr = document.createElement('tr');
                    var cols = [
                        ct.maSP,
                        ct.tenSP,
                        ct.donViTinh,
                        String(ct.soLuong),
                        Number(ct.giaBan || 0).toLocaleString('vi-VN') + ' đ',
                        ct.ghiChu || ''
                    ];
                    cols.forEach(function (val) {
                        var td = document.createElement('td');
                        td.textContent = val;
                        tr.appendChild(td);
                    });
                    tbody.appendChild(tr);
                });
            })
            .catch(function (err) {
                if (requestId !== detailRequest) return;
                console.error(err);
                tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#DC2626;">Lỗi tải chi tiết combo!</td></tr>';
            });
    }

    // Hộp thoại xác nhận trước khi xóa
    function xoaCombo(btn) {
        var ma = btn.getAttribute('data-ma');
        var ten = btn.getAttribute('data-ten');
        if (confirm('Bạn có chắc muốn xóa combo "' + ten + '" (' + ma + ') không?')) {
            var form = document.createElement('form');
            form.method = 'post'; form.action = '${pageContext.request.contextPath}/quan-ly-combo';
            [['action', 'delete'], ['id', ma], ['token', '${sessionScope.comboToken}']].forEach(function (pair) {
                var input = document.createElement('input'); input.type = 'hidden';
                input.name = pair[0]; input.value = pair[1]; form.appendChild(input);
            });
            document.body.appendChild(form); form.submit();
        }
    }

    // Tự động tính nhẩm tổng giá lẻ ban đầu nếu đang mở modal Sửa
    document.addEventListener('DOMContentLoaded', function () {
        tinhTongGiaLe('edit');
    });

    // COMBO - TÌM SẢN PHẨM: chỉ ẩn dòng, giữ nguyên các món đã chọn.
    function locSanPham(mode, keyword) {
        function normalize(text) {
            return text.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').toLowerCase();
        }
        var count = 0;
        document.querySelectorAll('#' + mode + 'PickerBody tr').forEach(function (row) {
            var visible = normalize(row.textContent).includes(normalize(keyword.trim()));
            row.hidden = !visible;
            if (visible) count++;
        });
        document.getElementById(mode + 'SearchEmpty').hidden = count > 0;
    }

    // COMBO - GIÁ: tính trên tất cả món đã tích, kể cả dòng đang bị tìm kiếm ẩn.
    function tinhTongGiaLe(mode) {
        var body = document.getElementById(mode + 'PickerBody');
        if (!body) return;
        var total = 0;
        body.querySelectorAll('input[type="checkbox"]:checked').forEach(function (checkbox) {
            var input = checkbox.closest('tr').querySelector('input[type="number"]');
            var quantity = Number(input.value);
            if (Number.isInteger(quantity) && quantity > 0)
                total += Number(checkbox.dataset.gia) * quantity;
        });
        document.getElementById(mode + 'TongGiaLe').textContent =
            'Tổng giá lẻ các món đã chọn: ' + total.toLocaleString('vi-VN') + ' đ';
        var rate = Number(document.getElementById(mode + 'GiamGia').value);
        var price = document.getElementById(mode + 'GiaCombo');
        price.value = rate === -1 ? price.dataset.original : Math.round(total * (100 - rate) / 100);
    }

    // COMBO - TỒN KHO: kiểm tra trước khi gửi; server vẫn kiểm tra lại khi lưu.
    function validateComboForm(mode) {
        var checked = document.querySelectorAll('#' + mode + 'PickerBody input[type="checkbox"]:checked');
        if (!checked.length) { alert('Hãy chọn ít nhất một sản phẩm.'); return false; }
        for (var checkbox of checked) {
            var input = checkbox.closest('tr').querySelector('input[type="number"]');
            var quantity = Number(input.value);
            if (checkbox.dataset.active !== 'true' || !Number.isInteger(quantity)
                    || quantity < 1 || quantity > Number(checkbox.dataset.stock)) {
                alert('Sản phẩm ' + checkbox.value + ': kiểm tra trạng thái và số lượng tồn (' + checkbox.dataset.stock + ').');
                return false;
            }
        }
        tinhTongGiaLe(mode);
        // Giữ bản nhập trong tab hiện tại nếu server trả lỗi, tránh phải nhập lại.
        try {
            var form = document.getElementById(mode + 'GiaCombo').form;
            sessionStorage.setItem('comboDraft', JSON.stringify(Array.from(new FormData(form).entries())));
        } catch (e) { /* Trình duyệt chặn lưu cục bộ vẫn cho phép gửi form. */ }
        return true;
    }

    // COMBO - KHỞI TẠO: khôi phục bản nhập lỗi; thao tác sửa thành phần sẽ tính giá mới.
    document.addEventListener('DOMContentLoaded', function () {
        ['add', 'edit'].forEach(function (mode) {
            var body = document.getElementById(mode + 'PickerBody');
            if (!body) return;
            // Nếu dòng lỗi đang bị bộ lọc ẩn, hiện lại để trình duyệt chỉ đúng ô cần sửa.
            body.addEventListener('invalid', function (event) {
                event.target.closest('tr').hidden = false;
            }, true);
            body.addEventListener('input', function () {
                var rate = document.getElementById(mode + 'GiamGia');
                if (rate.value === '-1') rate.value = '0';
                tinhTongGiaLe(mode);
            });
            tinhTongGiaLe(mode);
        });
        try {
            var params = new URLSearchParams(location.search);
            if (params.get('msg') === 'error') {
                var entries = JSON.parse(sessionStorage.getItem('comboDraft') || '[]');
                var action = entries.find(function (entry) { return entry[0] === 'action'; });
                var mode = action && action[1] === 'add' ? 'add' : 'edit';
                var price = document.getElementById(mode + 'GiaCombo');
                if (price) {
                    var form = price.form;
                    form.querySelectorAll('input[type="checkbox"]').forEach(function (el) { el.checked = false; toggleProductRow(el, mode); });
                    entries.forEach(function (entry) {
                        Array.from(form.elements).filter(function (el) { return el.name === entry[0]; })
                            .forEach(function (el) {
                                if (el.type === 'checkbox') {
                                    if (el.value === entry[1]) { el.checked = true; toggleProductRow(el, mode); }
                                } else if (el.name !== 'token' && el.name !== 'version' && el.name !== 'maCombo') el.value = entry[1];
                            });
                    });
                    tinhTongGiaLe(mode);
                    openModal(mode + 'ComboModal');
                }
            } else if (params.get('msg')) sessionStorage.removeItem('comboDraft');
        } catch (e) { /* Bản nháp không hợp lệ không cản trở trang. */ }
    });

</script>
</body>
</html>
