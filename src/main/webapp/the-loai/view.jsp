<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lí thể loại - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=12">
    <style>
        .pagination-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 24px;
            border-top: 1px solid #f1f5f9;
            background: #ffffff;
            border-radius: 0 0 16px 16px;
            flex-wrap: wrap;
            gap: 12px;
        }
        .pagination-info {
            font-size: 13px;
            color: #64748b;
            font-weight: 500;
        }
        .pagination-info strong {
            color: #1e293b;
            font-weight: 700;
        }
        .pagination-btns {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin-left: auto; /* Căn toàn bộ cụm nút sang góc phải */
        }
        .pg-btn {
            min-width: 36px;
            height: 36px;
            padding: 0 10px;
            border-radius: 10px;
            border: 1px solid #e2e8f0;
            background: #ffffff;
            color: #334155;
            font-size: 14px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
            user-select: none;
            box-sizing: border-box;
        }
        .pg-btn:hover:not(.disabled):not(.active) {
            border-color: #ff385c;
            color: #ff385c;
            background: #fff1f2;
        }
        .pg-btn.active {
            background: #ff385c !important;
            border-color: #ff385c !important;
            color: #ffffff !important;
            font-weight: 700;
            box-shadow: 0 4px 10px rgba(255, 56, 92, 0.4);
            cursor: default;
        }
        .pg-btn.disabled {
            opacity: 0.35;
            cursor: not-allowed;
            background: #ffffff;
            border-color: #f1f5f9;
            color: #94a3b8;
        }
    </style>
</head>
<body>
<div class="app-shell">
    <!-- MENU BÊN TRÁI -->
    <jsp:include page="/menuadmin.jsp" />

    <!-- NỘI DUNG QUẢN LÍ THỂ LOẠI -->
    <div class="main-wrapper">
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Quản lí thể loại</h2>
                </div>
            </div>
            <div class="topbar-right">
                <%-- [Ghi chú - Khánh]: Menu chính trỏ về Tổng quan /thong-ke --%>
                <a href="${pageContext.request.contextPath}/thong-ke" class="btn btn-ghost btn-sm">Menu chính</a>
            </div>
        </header>

        <main class="content-area">
            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Danh sách thể loại</div>
                        <div class="card-subtitle">Quản lý các thể loại phim đang chiếu tại rạp</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <button type="button" class="btn btn-pink" onclick="openAddTheLoai()">+ Thêm</button>
                        <span class="badge-pink">${listTheLoai.size()} thể loại</span>
                    </div>
                </div>

                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>STT</th>
                            <th>Mã thể loại</th>
                            <th>Tên thể loại</th>
                            <th>Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${listTheLoai}" var="item" varStatus="st">
                            <tr>
                                <%-- [PHÂN TRANG] STT được tính tiếp nối theo trang: (trang_hiện_tại - 1) * 5 + vị_trí + 1 --%>
                                <td>${(currentPage != null ? (currentPage - 1) * 5 : 0) + st.index + 1}</td>
                                <td><strong><c:out value="${item.maTheLoai}"/></strong></td>
                                <td><c:out value="${item.tenTheLoai}"/></td>
                                <td>
                                    <div class="action-group">
                                        <button type="button"
                                                class="btn btn-ghost btn-sm"
                                                data-ma="<c:out value='${item.maTheLoai}'/>"
                                                data-ten="<c:out value='${item.tenTheLoai}'/>"
                                                onclick="openDetailTheLoaiFromBtn(this)">Chi tiết</button>
                                        <button type="button"
                                                class="btn btn-outline btn-sm"
                                                data-ma="<c:out value='${item.maTheLoai}'/>"
                                                data-ten="<c:out value='${item.tenTheLoai}'/>"
                                                onclick="openEditTheLoaiFromBtn(this)">Sửa</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>

                <%-- =========================================================================
                     [PHÂN TRANG - GIAO DIỆN JSP]
                     Thanh điều hướng chuyển trang: «  ‹  1  2  ›  » căn góc bên phải
                     ========================================================================= --%>
                <c:if test="${totalPages > 1}">
                    <div class="pagination-bar">
                        <div class="pagination-info">
                            Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> (Tổng cộng: <strong>${totalItems}</strong> thể loại)
                        </div>

                        <div class="pagination-btns">
                            <%-- 1. Nút về Trang đầu («) --%>
                            <c:choose>
                                <c:when test="${currentPage > 1}">
                                    <a href="${pageContext.request.contextPath}/the-loai/view?page=1" class="pg-btn" title="Trang đầu">&laquo;</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="pg-btn disabled">&laquo;</span>
                                </c:otherwise>
                            </c:choose>

                            <%-- 2. Nút về Trang trước (‹) --%>
                            <c:choose>
                                <c:when test="${currentPage > 1}">
                                    <a href="${pageContext.request.contextPath}/the-loai/view?page=${currentPage - 1}" class="pg-btn" title="Trang trước">&lsaquo;</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="pg-btn disabled">&lsaquo;</span>
                                </c:otherwise>
                            </c:choose>

                            <%-- 3. Vòng lặp in các nút số trang (1, 2...) --%>
                            <c:forEach begin="1" end="${totalPages}" var="p">
                                <a href="${pageContext.request.contextPath}/the-loai/view?page=${p}"
                                   class="pg-btn ${currentPage == p ? 'active' : ''}">
                                    ${p}
                                </a>
                            </c:forEach>

                            <%-- 4. Nút sang Trang sau (›) --%>
                            <c:choose>
                                <c:when test="${currentPage < totalPages}">
                                    <a href="${pageContext.request.contextPath}/the-loai/view?page=${currentPage + 1}" class="pg-btn" title="Trang sau">&rsaquo;</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="pg-btn disabled">&rsaquo;</span>
                                </c:otherwise>
                            </c:choose>

                            <%-- 5. Nút sang Trang cuối (») --%>
                            <c:choose>
                                <c:when test="${currentPage < totalPages}">
                                    <a href="${pageContext.request.contextPath}/the-loai/view?page=${totalPages}" class="pg-btn" title="Trang cuối">&raquo;</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="pg-btn disabled">&raquo;</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:if>
            </div>
        </main>
    </div>
</div>

<!-- POP-UP THÊM THỂ LOẠI -->
<div class="modal-backdrop ${openModal == 'add' ? 'open' : ''}" id="addTheLoaiModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Thêm thể loại</h3>
            <button type="button" class="modal-close" onclick="closeModal('addTheLoaiModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'add' and not empty error}">
            <div class="alert-error" id="addTheLoaiError"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/the-loai/add" method="post">
            <div class="form-stack">
                <div class="form-group">
                    <label for="addMaTheLoai">Mã thể loại</label>
                    <input type="text" id="addMaTheLoai" name="maTheLoai" class="form-control"
                           value="Tự động sinh (Auto ID)" readonly style="background: var(--bg-input); cursor: not-allowed; color: var(--text-secondary);">
                </div>
                <div class="form-group">
                    <label for="addTenTheLoai">Tên thể loại<span class="required-star">*</span></label>
                    <input type="text" id="addTenTheLoai" name="tenTheLoai" class="form-control"
                           value="${openModal == 'add' ? tl.tenTheLoai : ''}"
                           placeholder="VD: Cổ Trang">
                </div>
                <div style="font-size:12px; color:var(--text-secondary);">
                    (<span class="required-star">*</span>) Trường bắt buộc nhập
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addTheLoaiModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Thêm</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP SỬA THỂ LOẠI -->
<div class="modal-backdrop ${openModal == 'update' ? 'open' : ''}" id="editTheLoaiModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Sửa thể loại</h3>
            <button type="button" class="modal-close" onclick="closeModal('editTheLoaiModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'update' and not empty error}">
            <div class="alert-error" id="editTheLoaiError"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/the-loai/update" method="post">
            <div class="form-stack">
                <div class="form-group">
                    <label for="editMaTheLoai">Mã thể loại<span class="required-star">*</span></label>
                    <input type="text" id="editMaTheLoai" name="maTheLoai" class="form-control"
                           value="${openModal == 'update' ? tl.maTheLoai : ''}" readonly>
                </div>
                <div class="form-group">
                    <label for="editTenTheLoai">Tên thể loại<span class="required-star">*</span></label>
                    <input type="text" id="editTenTheLoai" name="tenTheLoai" class="form-control"
                           value="${openModal == 'update' ? tl.tenTheLoai : ''}">
                </div>
                <div style="font-size:12px; color:var(--text-secondary);">
                    (<span class="required-star">*</span>) Trường bắt buộc nhập
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('editTheLoaiModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Lưu cập nhật</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP CHI TIẾT THỂ LOẠI -->
<div class="modal-backdrop ${openModal == 'detail' ? 'open' : ''}" id="detailTheLoaiModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Chi tiết thể loại</h3>
            <button type="button" class="modal-close" onclick="closeModal('detailTheLoaiModal')">&times;</button>
        </div>
        <div class="form-stack">
            <div class="form-group">
                <label>Mã thể loại</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailMaTheLoai"><c:out value="${tl.maTheLoai}"/></div>
            </div>
            <div class="form-group">
                <label>Tên thể loại</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailTenTheLoai"><c:out value="${tl.tenTheLoai}"/></div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-pink" onclick="closeModal('detailTheLoaiModal')">Đóng</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=9"></script>
</body>
</html>