<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:if test="${requestScope.dsCombo == null}"><c:redirect url="/quan-ly-combo"/></c:if>
<%-- [CB-VIEW] Form gửi Servlet -> Repository -> dữ liệu trả về JSP. Tra cứu: docs/TRA_CUU_COMBO_SAN_PHAM_THONG_KE.txt --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lí Combo - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=7">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/anh-danh-muc.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/quan-ly-combo.css?v=1">
</head>
<body>
<div class="app-shell">
    <!-- MENU BÊN TRÁI HỆ THỐNG (ĐỒNG BỘ ĐẦY ĐỦ 100% CHỨC NĂNG) -->
    <c:choose>
        <c:when test="${sessionScope.userRole == 'NhanVien' || sessionScope.userRole == 'Nhân viên'}">
            <jsp:include page="/menunv.jsp" />
        </c:when>
        <c:otherwise>
            <jsp:include page="/menuadmin.jsp" />
        </c:otherwise>
    </c:choose>

    <!-- NỘI DUNG CHÍNH -->
    <div class="main-wrapper">
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Quản lí combo bắp nước</h2>
                </div>
            </div>
            <div class="topbar-right">
                <%-- [Ghi chú - Khánh]: Menu chính trỏ về Tổng quan /thong-ke --%>
                <a href="${pageContext.request.contextPath}/thong-ke" class="btn btn-ghost btn-sm">Menu chính</a>
            </div>
        </header>

        <main class="content-area">
<c:if test="${not empty param.error}"><div class="alert-error"><c:out value="${param.error}"/></div></c:if>

            <%-- Thông báo trạng thái --%>
            <c:if test="${param.msg == 'add_ok'}">
                <div class="alert-success">Thêm combo thành công!</div>
            </c:if>
            <c:if test="${param.msg == 'update_ok'}">
                <div class="alert-success">Cập nhật combo thành công!</div>
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
                <div class="alert-error">Mã combo đã tồn tại!</div>
            </c:if>
            <c:if test="${param.msg == 'invalid_data' || param.msg == 'error'}">
                <div class="alert-error">Dữ liệu không hợp lệ hoặc thao tác thất bại!</div>
            </c:if>

            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Danh sách combo</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
                        <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="btn btn-outline">Quản lí sản phẩm</a>
                        <button type="button" class="btn btn-pink" onclick="openModal('addComboModal')">+ Thêm combo</button>
                        <span class="badge-pink">${dsCombo.size()} combo</span>
                    </div>
                </div>

                <%-- Thanh tìm kiếm & lọc --%>
                <%-- [CB-TIM-KIEM] Gửi bộ lọc tới Servlet bằng GET. --%>
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

                <%-- BẢNG COMBO: STT -> Hình ảnh -> Mã Combo -> Tên Combo -> ... --%>
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
                                <td>
                                    <c:set var="imgName" value="${not empty cb.hinhAnh ? cb.hinhAnh : cb.maCombo.toString().concat('.jpg')}"/>
                                    <c:url var="anhCombo" value="/anh-danh-muc"><c:param name="loai" value="combo"/><c:param name="ten" value="${imgName}"/></c:url>
                                    <img class="combo-thumb"
                                         src="<c:out value='${anhCombo}'/>" alt="Ảnh combo" loading="lazy"
                                         onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                    <div class="combo-thumb-placeholder">Chưa có ảnh</div>
                                </td>
                                <td><strong><c:out value="${cb.maCombo}"/></strong></td>
                                <td><c:out value="${cb.tenCombo}"/></td>
                                <td><strong><fmt:formatNumber value="${cb.giaCombo}" pattern="#,###"/> đ</strong></td>
                                <td><c:out value="${cb.moTa}"/></td>
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
                                <td>
                                    <div class="action-group">
                                        <button type="button" class="btn btn-ghost btn-sm"
                                                data-ma="<c:out value='${cb.maCombo}'/>"
                                                data-ten="<c:out value='${cb.tenCombo}'/>"
                                                data-gia="<fmt:formatNumber value='${cb.giaCombo}' pattern='#,###'/> đ"
                                                data-mota="<c:out value='${cb.moTa}'/>"
                                                data-anh="<c:out value='${anhCombo}'/>"
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

<!-- POP-UP THÊM COMBO (Tích chọn sản phẩm trực tiếp bằng Checkbox) -->
<div class="modal-backdrop" id="addComboModal">
    <div class="modal-box modal-box-lg">
        <div class="modal-header">
            <h3>Thêm combo mới</h3>
            <button type="button" class="modal-close" onclick="closeModal('addComboModal')">&times;</button>
        </div>

        <%-- [CB-FORM] action=add: thêm; update: sửa; delete: xóa. --%>
<form action="${pageContext.request.contextPath}/quan-ly-combo" method="post" enctype="multipart/form-data" onsubmit="return validateComboForm('add')">
            <input type="hidden" name="token" value="${sessionScope.comboToken}">
<input type="hidden" name="action" value="add">
            <div class="form-grid">
                <div class="form-group">
                    <label>Mã combo<span class="required-star">*</span></label>
                    <input type="text" class="form-control" value="Tự động khi lưu" readonly>
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
                    <%-- Thêm mới luôn đang bán; server cũng kiểm tra. --%><input class="form-control" value="Đang bán" readonly>
                </div>
                <%-- [CB-CHON-ANH] Chọn file từ máy, rồi gửi cùng tên và thành phần combo. --%>
                <div class="form-group">
                    <label for="addComboAnh">Ảnh combo</label>
                    <input id="addComboAnh" name="tepAnh" type="file" accept="image/jpeg,image/png,.jpg,.jpeg,.png"
                           data-anh-preview="addComboPreview" aria-describedby="addComboAnhGoiY" hidden>
                    <div class="anh-danh-muc-chon" data-anh-control>
                        <button type="button" class="btn btn-outline" aria-controls="addComboAnh" aria-describedby="addComboAnhGoiY">+ Thêm ảnh</button>
                        <span class="anh-danh-muc-ten" role="status">Chưa chọn tệp</span>
                    </div>
                    <small id="addComboAnhGoiY" class="anh-danh-muc-goi-y">JPG hoặc PNG, tối đa 5 MB.</small>
                    <img id="addComboPreview" class="anh-danh-muc-xem-truoc" alt="Xem trước ảnh combo" hidden>
                </div>
                <div class="form-group">
                    <label>Mô tả</label>
                    <input type="text" name="moTa" class="form-control" placeholder="VD: 1 Bắp lớn + 2 Nước ngọt">
                </div>
            </div>

            <%-- COMBO: mức giảm trên tổng giá lẻ. --%><div class="form-group"><label>Mức giảm giá</label><select class="form-control" name="giamGia" id="addGiamGia" onchange="tinhTongGiaLe('add')"><option value="0">Không giảm</option><option value="10">Giảm 10%</option><option value="20">Giảm 20%</option><option value="50">Giảm 50%</option></select></div>
<div class="combo-detail-box">
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <strong style="font-size:13px;">Tích chọn sản phẩm đưa vào combo<span class="required-star">*</span></strong>
                    <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="btn btn-ghost btn-sm">+ Thêm sản phẩm mới</a>
                </div>

                <input type="search" class="form-control" placeholder="Tìm mã hoặc tên sản phẩm..." oninput="locSanPham('add',this.value)"><p id="addEmpty" hidden>Không tìm thấy sản phẩm.</p>
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
                                <td>
                                    <input type="number" name="ctSoLuong_${sp.maSP}" value="1" min="1" max="${sp.soLuongTon}" required
                                           class="form-control" style="padding:6px 8px;" disabled
                                           onchange="tinhTongGiaLe('add')">
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
                <div class="tong-gia-le" id="addTongGiaLe">Tổng giá lẻ các món đã chọn: 0 đ</div>
            </div>

            <div class="modal-footer" style="margin-top:16px;">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addComboModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Lưu combo</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP SỬA COMBO -->
<c:if test="${editCombo != null}">
    <div class="modal-backdrop open" id="editComboModal">
        <div class="modal-box modal-box-lg">
            <div class="modal-header">
                <h3>Sửa combo: <c:out value="${editCombo.maCombo}"/></h3>
                <a href="${pageContext.request.contextPath}/quan-ly-combo" class="modal-close">&times;</a>
            </div>

            <%-- [CB-FORM] action=add: thêm; update: sửa; delete: xóa. --%>
<form action="${pageContext.request.contextPath}/quan-ly-combo" method="post" enctype="multipart/form-data" onsubmit="return validateComboForm('edit')">
                <input type="hidden" name="token" value="${sessionScope.comboToken}">
<input type="hidden" name="version" value="${version}">
<input type="hidden" name="action" value="update">
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
                        <label for="editComboAnh">Thay ảnh combo</label>
                        <input id="editComboAnh" name="tepAnh" type="file" accept="image/jpeg,image/png,.jpg,.jpeg,.png"
                               data-anh-preview="editComboPreview" aria-describedby="editComboAnhGoiY" hidden>
                        <div class="anh-danh-muc-chon" data-anh-control>
                            <button type="button" class="btn btn-outline" aria-controls="editComboAnh" aria-describedby="editComboAnhGoiY">+ Thêm ảnh</button>
                            <span class="anh-danh-muc-ten" role="status">Chưa chọn tệp mới</span>
                        </div>
                        <small id="editComboAnhGoiY" class="anh-danh-muc-goi-y">Bỏ trống để giữ ảnh hiện tại. JPG hoặc PNG, tối đa 5 MB.</small>
                        <c:set var="tenAnhSua" value="${not empty editCombo.hinhAnh ? editCombo.hinhAnh : editCombo.maCombo.toString().concat('.jpg')}"/>
                        <c:url var="anhComboSua" value="/anh-danh-muc"><c:param name="loai" value="combo"/><c:param name="ten" value="${tenAnhSua}"/></c:url>
                        <img id="editComboPreview" class="anh-danh-muc-xem-truoc" src="<c:out value='${anhComboSua}'/>"
                             alt="Xem trước ảnh combo" onerror="this.hidden=true;">
                    </div>
                    <div class="form-group">
                        <label>Mô tả</label>
                        <input type="text" name="moTa" class="form-control" value="<c:out value='${editCombo.moTa}'/>">
                    </div>
                </div>

                <%-- COMBO: mức giảm trên tổng giá lẻ. --%><div class="form-group"><label>Mức giảm giá</label><select class="form-control" name="giamGia" id="editGiamGia" onchange="tinhTongGiaLe('edit')"><option value="-1">Giữ giá đã lưu</option><option value="0">Không giảm</option><option value="10">Giảm 10%</option><option value="20">Giảm 20%</option><option value="50">Giảm 50%</option></select></div>
<div class="combo-detail-box">
                    <strong style="font-size:13px;">Tích chọn sản phẩm bên trong combo<span class="required-star">*</span></strong>
                    <input type="search" class="form-control" placeholder="Tìm mã hoặc tên sản phẩm..." oninput="locSanPham('edit',this.value)"><p id="editEmpty" hidden>Không tìm thấy sản phẩm.</p>
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
                                               value="${isChecked ? ctItem.soLuong : 1}" min="1" required
                                               class="form-control" style="padding:6px 8px;"
                                            ${isChecked ? '' : 'disabled'}
                                               onchange="tinhTongGiaLe('edit')">
                                    </td>
                                    <td>
                                        <input type="text" maxlength="100" name="ctGhiChu_${sp.maSP}"
                                               value="<c:out value='${isChecked ? ctItem.ghiChu : ""}'/>"
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

<!-- POP-UP CHI TIẾT COMBO -->
<div class="modal-backdrop" id="detailComboModal">
    <div class="modal-box modal-box-lg">
        <div class="modal-header">
            <h3>Chi tiết combo</h3>
            <button type="button" class="modal-close" onclick="closeModal('detailComboModal')">&times;</button>
        </div>
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
                <span>Ảnh combo</span>
                <img class="anh-danh-muc-xem-truoc" id="dtHinhAnh" alt="Ảnh combo" hidden
                     onerror="this.hidden=true; this.nextElementSibling.hidden=false;">
                <span id="dtChuaCoAnh">Chưa có ảnh</span>
            </div>
        </div>
        <div class="form-group" style="margin-bottom:14px;">
            <label>Mô tả</label>
            <div class="form-control" style="background:var(--bg-input);" id="dtMoTa"></div>
        </div>
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

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=5"></script>
<script src="${pageContext.request.contextPath}/assets/js/anh-danh-muc.js?v=3"></script>
<%-- [CB-XOA-FORM] Chỉ gửi POST; token được tạo trong phiên làm việc. --%>
<%-- [CB-FORM] action=add: thêm; update: sửa; delete: xóa. --%>
<form id="deleteComboForm" method="post" action="${pageContext.request.contextPath}/quan-ly-combo">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="id">
    <input type="hidden" name="token" value="${sessionScope.comboToken}">
</form>
<script src="${pageContext.request.contextPath}/assets/js/quan-ly-combo.js?v=1"></script>
</body>
</html>
