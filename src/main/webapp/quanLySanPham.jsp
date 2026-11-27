<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<%-- Dữ liệu và mã gợi ý luôn được tải qua servlet. --%>
<c:if test="${requestScope.dsSanPham == null}"><c:redirect url="/quan-ly-san-pham"/></c:if>
<%-- [SP-VIEW] Form gửi Servlet -> Repository -> dữ liệu trả về JSP. Tra cứu: docs/TRA_CUU_COMBO_SAN_PHAM_THONG_KE.txt --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lí Sản phẩm - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=7">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/anh-danh-muc.css?v=2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/quan-ly-san-pham.css?v=1">
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
                    <h2>Quản lí sản phẩm (Bắp - Nước - Snack)</h2>
                </div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/quan-ly-combo" class="btn btn-outline btn-sm">Sang Quản lí combo</a>
            </div>
        </header>

        <main class="content-area">

            <c:if test="${param.msg == 'add_ok'}">
                <div class="alert-success">Thêm sản phẩm thành công!</div>
            </c:if>
            <c:if test="${param.msg == 'update_ok'}">
                <div class="alert-success">Cập nhật sản phẩm thành công!</div>
            </c:if>
            <c:if test="${param.msg == 'stale'}">
                <div class="alert-error">Sản phẩm đã thay đổi hoặc đã bị xóa. Hãy mở lại form sửa để xem dữ liệu mới nhất.</div>
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
                <div class="alert-error">Dữ liệu không hợp lệ hoặc thao tác thất bại! <c:out value="${param.error}"/></div>
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
                <%-- [SP-TIM-KIEM] Gửi bộ lọc tới Servlet bằng GET. --%>
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
                            <th>Hình ảnh</th>
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
                                <%-- [SP-HIEN-ANH] Đọc tên ảnh từ SanPham.HinhAnh rồi gọi servlet cung cấp ảnh. --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty sp.hinhAnh}">
                                            <c:url var="anhSanPham" value="/anh-danh-muc"><c:param name="ten" value="${sp.hinhAnh}"/></c:url>
                                            <img src="<c:out value='${anhSanPham}'/>" alt="Ảnh sản phẩm" width="64" height="52"
                                                 style="object-fit:contain; border-radius:6px;" onerror="this.hidden=true; this.nextElementSibling.hidden=false;">
                                            <span hidden>Chưa có ảnh</span>
                                        </c:when>
                                        <c:otherwise>Chưa có ảnh</c:otherwise>
                                    </c:choose>
                                </td>
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
                                <td colspan="10" style="text-align:center; color:var(--text-secondary);">Không có sản phẩm nào.</td>
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

        <%-- [SP-FORM] action=add: thêm; update: sửa; delete: xóa. --%>
<form action="${pageContext.request.contextPath}/quan-ly-san-pham" method="post" enctype="multipart/form-data">
            <input type="hidden" name="token" value="${sessionScope.sanPhamToken}">
            <input type="hidden" name="action" value="add">
            <%-- [SP-THEM-ANH] Gửi file tepAnh tới SanPhamServlet.luuSanPhamCoAnh. --%>
            <div class="form-group">
                <label for="addSPAnh">Ảnh sản phẩm</label>
                <input id="addSPAnh" name="tepAnh" type="file" accept="image/jpeg,image/png,.jpg,.jpeg,.png"
                       class="form-control" data-sp-anh aria-describedby="addSPAnhGoiY">
                <div class="anh-danh-muc-chon">
                    <button type="button" class="btn btn-outline" data-sp-chon-anh aria-controls="addSPAnh">+ Thêm ảnh</button>
                    <span class="anh-danh-muc-ten" role="status">Chưa chọn tệp</span>
                </div>
                <small id="addSPAnhGoiY" class="anh-danh-muc-goi-y">JPG hoặc PNG, tối đa 5 MB.</small>
                <img class="anh-danh-muc-xem-truoc" alt="Xem trước ảnh sản phẩm" hidden>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label>Mã sản phẩm<span class="required-star">*</span></label>
                    <input type="text" class="form-control" value="Tự động khi lưu" readonly>
                </div>
                <div class="form-group">
                    <label>Tên sản phẩm<span class="required-star">*</span></label>
                    <input type="text" name="tenSP" class="form-control" placeholder="VD: Bắp Caramel (Vừa)" required>
                </div>
                <div class="form-group">
                    <label>Loại sản phẩm<span class="required-star">*</span></label>
                    <select name="loaiSP" class="form-control" required onchange="goiYDonVi(this)">
<option value="" selected disabled>Chọn loại sản phẩm</option>
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
<option value="" selected disabled>Chọn đơn vị tính</option>
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
                    <input type="number" name="soLuongTon" class="form-control" min="0" value="0" required>
                </div>
            </div>
            <div class="form-group" style="margin-bottom:14px;">
                <label>Trạng thái</label>
                <%-- SẢN PHẨM: trạng thái thêm mới cố định, sửa mới được ngừng bán. --%>
<input class="form-control" value="Đang kinh doanh" readonly>
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

            <%-- [SP-FORM] action=add: thêm; update: sửa; delete: xóa. --%>
<form action="${pageContext.request.contextPath}/quan-ly-san-pham" method="post" enctype="multipart/form-data">
                <input type="hidden" name="token" value="${sessionScope.sanPhamToken}">
                <input type="hidden" name="version" value="${version}">
                <input type="hidden" name="action" value="update">
                <%-- [SP-SUA-ANH] Không chọn tệp mới: repository giữ nguyên ảnh đã lưu. --%>
                <div class="form-group">
                    <label for="editSPAnh">Thay ảnh sản phẩm</label>
                    <input id="editSPAnh" name="tepAnh" type="file" accept="image/jpeg,image/png,.jpg,.jpeg,.png"
                           class="form-control" data-sp-anh aria-describedby="editSPAnhGoiY">
                    <div class="anh-danh-muc-chon">
                        <button type="button" class="btn btn-outline" data-sp-chon-anh aria-controls="editSPAnh">+ Thêm ảnh</button>
                        <span class="anh-danh-muc-ten" role="status">Chưa chọn tệp mới</span>
                    </div>
                    <small id="editSPAnhGoiY" class="anh-danh-muc-goi-y">Bỏ trống để giữ ảnh hiện tại. JPG hoặc PNG, tối đa 5 MB.</small>
                    <c:url var="anhSanPhamSua" value="/anh-danh-muc"><c:param name="ten" value="${editSP.hinhAnh}"/></c:url>
                    <img class="anh-danh-muc-xem-truoc" src="<c:out value='${anhSanPhamSua}'/>"
                         alt="Xem trước ảnh sản phẩm" ${empty editSP.hinhAnh ? 'hidden' : ''} onerror="this.hidden=true;">
                </div>
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

<%-- [SP-XOA] Nút xóa xác nhận rồi gửi mã qua form POST. --%>
<%-- [SP-FORM] action=add: thêm; update: sửa; delete: xóa. --%>
<form id="deleteProductForm" method="post" action="${pageContext.request.contextPath}/quan-ly-san-pham">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="token" value="${sessionScope.sanPhamToken}">
    <input type="hidden" name="id">
</form>
<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=5"></script>
<script src="${pageContext.request.contextPath}/assets/js/san-pham-anh.js?v=1"></script>
<script src="${pageContext.request.contextPath}/assets/js/quan-ly-san-pham.js?v=1"></script>
</body>
</html>
