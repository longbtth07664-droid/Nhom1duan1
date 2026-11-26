<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách phim - Rạp Chiếu Phim CINEMAX</title>
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
            margin-top: 16px;
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

    <!-- NỘI DUNG CHÍNH -->
    <div class="main-wrapper">
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Danh sách phim</h2>
                </div>
            </div>
            <div class="topbar-right">
                <%-- [Ghi chú - Khánh]: Menu chính trỏ về Tổng quan /thong-ke --%>
                <a href="${pageContext.request.contextPath}/thong-ke" class="btn btn-ghost btn-sm">Menu chính</a>
            </div>
        </header>

        <main class="content-area">
            <!-- 1. BỘ LỌC & TÌM KIẾM PHIM (DIV RIÊNG BIỆT) -->
            <div class="card" style="margin-bottom: 20px;">
                <div class="card-header" style="margin-bottom: 12px;">
                    <div>
                        <div class="card-title">Bộ lọc & Tìm kiếm phim</div>
                        <div class="card-subtitle">Tìm kiếm phim theo từ khóa hoặc lọc theo thể loại</div>
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/phim/view" method="get" class="filter-bar" style="display:flex; flex-wrap:wrap; gap:12px; align-items:center;">
                    <input type="hidden" name="action" value="search">
                    <input type="text" name="keyword" class="form-control" style="max-width: 320px;"
                           placeholder="Nhập mã phim, tên phim, đạo diễn..." value="<c:out value='${keyword}'/>">

                    <select name="maTheLoai" class="form-control" style="max-width: 220px;">
                        <option value="" ${empty selectedTheLoai || selectedTheLoai == 'Tất cả' ? 'selected' : ''}>-- Tất cả thể loại --</option>
                        <c:forEach items="${listTheLoai}" var="tl">
                            <option value="${tl.maTheLoai}" ${selectedTheLoai == tl.maTheLoai.toString() ? 'selected' : ''}>
                                <c:out value="${tl.tenTheLoai}"/>
                            </option>
                        </c:forEach>
                    </select>
                    <select name="trangThai" class="form-control" style="max-width: 180px;">
                        <option value="" ${empty selectedTrangThai ? 'selected' : ''}>-- Tất cả trạng thái --</option>
                        <option value="Đang chiếu" ${selectedTrangThai == 'Đang chiếu' ? 'selected' : ''}>Đang chiếu</option>
                        <option value="Sắp chiếu" ${selectedTrangThai == 'Sắp chiếu' ? 'selected' : ''}>Sắp chiếu</option>
                        <option value="Ngừng chiếu" ${selectedTrangThai == 'Ngừng chiếu' ? 'selected' : ''}>Ngừng chiếu</option>
                    </select>

                    <button type="submit" class="btn btn-pink">Tìm kiếm</button>
                    <a href="${pageContext.request.contextPath}/phim/view" class="btn btn-ghost">Làm mới</a>
                </form>
            </div>

            <!-- 2. DANH SÁCH PHIM -->
            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Danh sách phim</div>
                        <div class="card-subtitle">Quản lý thông tin, thể loại và lịch chiếu của các bộ phim tại rạp</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <button type="button" class="btn btn-pink" onclick="openAddPhim()">+ Thêm</button>
                        <span class="badge-pink">${totalItems != null ? totalItems : listPhim.size()} phim</span>
                    </div>
                </div>



                <div class="movie-grid">
                    <c:if test="${empty listPhim}">
                        <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: var(--text-secondary);">
                            <p style="font-size: 16px; margin-bottom: 8px;">Không tìm thấy bộ phim nào phù hợp!</p>
                            <a href="${pageContext.request.contextPath}/phim/view" class="btn btn-ghost btn-sm">Xem tất cả phim</a>
                        </div>
                    </c:if>
                    <c:forEach items="${listPhim}" var="item">
                        <article class="movie-card">
                            <div class="movie-poster">
                                <span class="movie-code-badge"><c:out value="${item.maPhim}"/></span>
                                <span class="movie-age-badge"><c:out value="${not empty item.doTuoi ? item.doTuoi : 'P'}"/></span>

                                <div class="movie-poster-fallback">
                                    <span class="poster-label">CINEMAX</span>
                                    <div class="poster-title"><c:out value="${item.tenPhim}"/></div>
                                </div>

                                <c:if test="${not empty item.poster}">
                                    <c:choose>
                                        <c:when test="${item.poster.startsWith('http://') or item.poster.startsWith('https://')}">
                                            <img src="<c:out value='${item.poster}'/>" alt="<c:out value='${item.tenPhim}'/>" onerror="this.style.display='none'">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/assets/images/<c:out value='${item.poster}'/>" alt="<c:out value='${item.tenPhim}'/>" onerror="this.style.display='none'">
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </div>

                            <div class="movie-body">
                                <div class="movie-title"><c:out value="${item.tenPhim}"/></div>
                                <div class="movie-genres">
                                    <c:choose>
                                        <c:when test="${not empty item.tenTheLoaisStr}">
                                            <c:out value="${item.tenTheLoaisStr}"/>
                                        </c:when>
                                        <c:otherwise>Chưa gán thể loại</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="movie-formats" style="margin-top: 4px; display: flex; gap: 4px; flex-wrap: wrap;">
                                    <c:choose>
                                        <c:when test="${not empty item.tenDinhDangsStr}">
                                            <c:forEach items="${item.dinhDangs}" var="dd">
                                                <span style="display:inline-block; font-size:11px; font-weight:700; padding:2px 7px; border-radius:6px; background:#e0e7ff; color:#4338ca;">
                                                    <c:out value="${dd.tenDinhDang}"/>
                                                </span>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="font-size:11px; color:#94a3b8; font-style:italic;">Chưa gán định dạng</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="movie-meta">
                                    <div>Thời lượng: <strong>${item.thoiLuong} phút</strong></div>
                                    <div>Khởi chiếu: ${item.ngayKhoiChieu} - ${item.ngayKetThuc}</div>
                                    <c:if test="${not empty item.daoDien}">
                                        <div>Đạo diễn: <c:out value="${item.daoDien}"/></div>
                                    </c:if>
                                    <c:if test="${not empty item.trangThai}">
                                        <div>Trạng thái: <span style="display:inline-block; font-size:11px; font-weight:600; padding:2px 8px; border-radius:4px; background: ${item.trangThai == 'Đang chiếu' ? '#dcfce7; color:#15803d;' : (item.trangThai == 'Sắp chiếu' ? '#fef9c3; color:#a16207;' : '#f1f5f9; color:#475569;')}"><c:out value="${item.trangThai}"/></span></div>
                                    </c:if>
                                </div>
                            </div>

                            <div class="movie-actions">
                                <button type="button"
                                        class="btn btn-ghost btn-sm"
                                        data-ma="<c:out value='${item.maPhim}'/>"
                                        data-ten="<c:out value='${item.tenPhim}'/>"
                                        data-thoiluong="${item.thoiLuong}"
                                        data-thoiluong-text="${item.thoiLuong} phút"
                                        data-khoichieu="${item.ngayKhoiChieu}"
                                        data-ketthuc="${item.ngayKetThuc}"
                                        data-daodien="<c:out value='${item.daoDien}'/>"
                                        data-dienvien="<c:out value='${item.dienVien}'/>"
                                        data-dotuoi="<c:out value='${item.doTuoi}'/>"
                                        data-poster="<c:out value='${item.poster}'/>"
                                        data-trailer="<c:out value='${item.trailer}'/>"
                                        data-quocgia="<c:out value='${item.quocGia}'/>"
                                        data-trangthai="<c:out value='${item.trangThai}'/>"
                                        data-mota="<c:out value='${item.moTa}'/>"
                                        data-tentheloais="<c:out value='${item.tenTheLoaisStr}'/>"
                                        data-matheloais="<c:out value='${item.maTheLoaisStr}'/>"
                                        data-tendinhdangs="<c:out value='${item.tenDinhDangsStr}'/>"
                                        data-madinhdangs="<c:out value='${item.maDinhDangsStr}'/>"
                                        onclick="openDetailPhimFromBtn(this)">Chi tiết</button>
                                <button type="button"
                                        class="btn btn-outline btn-sm"
                                        data-ma="<c:out value='${item.maPhim}'/>"
                                        data-ten="<c:out value='${item.tenPhim}'/>"
                                        data-thoiluong="${item.thoiLuong}"
                                        data-khoichieu="${item.ngayKhoiChieu}"
                                        data-ketthuc="${item.ngayKetThuc}"
                                        data-daodien="<c:out value='${item.daoDien}'/>"
                                        data-dienvien="<c:out value='${item.dienVien}'/>"
                                        data-dotuoi="<c:out value='${item.doTuoi}'/>"
                                        data-poster="<c:out value='${item.poster}'/>"
                                        data-trailer="<c:out value='${item.trailer}'/>"
                                        data-quocgia="<c:out value='${item.quocGia}'/>"
                                        data-trangthai="<c:out value='${item.trangThai}'/>"
                                        data-mota="<c:out value='${item.moTa}'/>"
                                        data-matheloais="<c:out value='${item.maTheLoaisStr}'/>"
                                        data-madinhdangs="<c:out value='${item.maDinhDangsStr}'/>"
                                        onclick="openEditPhimFromBtn(this)">Sửa</button>
                            </div>
                        </article>
                    </c:forEach>
                </div>

                <%-- =========================================================================
                     [PHÂN TRANG - GIAO DIỆN JSP]
                     Thanh điều hướng chuyển trang cho danh sách phim:
                     - «  ‹  1  2  ›  » căn góc bên phải
                     - Giữ nguyên từ khóa tìm kiếm (keyword) và thể loại (maTheLoai) khi chuyển trang
                     ========================================================================= --%>
                <c:if test="${totalPages > 1}">
                    <div class="pagination-bar">
                        <div class="pagination-info">
                            Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> (Tổng cộng: <strong>${totalItems}</strong> bộ phim)
                        </div>

                        <div class="pagination-btns">
                            <%-- 1. Nút về Trang đầu («) --%>
                            <c:choose>
                                <c:when test="${currentPage > 1}">
                                    <a href="${pageContext.request.contextPath}/phim/view?action=search&keyword=<c:out value='${keyword}'/>&maTheLoai=<c:out value='${selectedTheLoai}'/>&trangThai=<c:out value='${selectedTrangThai}'/>&page=1" class="pg-btn" title="Trang đầu">&laquo;</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="pg-btn disabled">&laquo;</span>
                                </c:otherwise>
                            </c:choose>

                            <%-- 2. Nút về Trang trước (‹) --%>
                            <c:choose>
                                <c:when test="${currentPage > 1}">
                                    <a href="${pageContext.request.contextPath}/phim/view?action=search&keyword=<c:out value='${keyword}'/>&maTheLoai=<c:out value='${selectedTheLoai}'/>&trangThai=<c:out value='${selectedTrangThai}'/>&page=${currentPage - 1}" class="pg-btn" title="Trang trước">&lsaquo;</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="pg-btn disabled">&lsaquo;</span>
                                </c:otherwise>
                            </c:choose>

                            <%-- 3. Vòng lặp in các nút số trang (1, 2...) --%>
                            <c:forEach begin="1" end="${totalPages}" var="p">
                                <a href="${pageContext.request.contextPath}/phim/view?action=search&keyword=<c:out value='${keyword}'/>&maTheLoai=<c:out value='${selectedTheLoai}'/>&trangThai=<c:out value='${selectedTrangThai}'/>&page=${p}"
                                   class="pg-btn ${currentPage == p ? 'active' : ''}">
                                    ${p}
                                </a>
                            </c:forEach>

                            <%-- 4. Nút sang Trang sau (›) --%>
                            <c:choose>
                                <c:when test="${currentPage < totalPages}">
                                    <a href="${pageContext.request.contextPath}/phim/view?action=search&keyword=<c:out value='${keyword}'/>&maTheLoai=<c:out value='${selectedTheLoai}'/>&trangThai=<c:out value='${selectedTrangThai}'/>&page=${currentPage + 1}" class="pg-btn" title="Trang sau">&rsaquo;</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="pg-btn disabled">&rsaquo;</span>
                                </c:otherwise>
                            </c:choose>

                            <%-- 5. Nút sang Trang cuối (») --%>
                            <c:choose>
                                <c:when test="${currentPage < totalPages}">
                                    <a href="${pageContext.request.contextPath}/phim/view?action=search&keyword=<c:out value='${keyword}'/>&maTheLoai=<c:out value='${selectedTheLoai}'/>&trangThai=<c:out value='${selectedTrangThai}'/>&page=${totalPages}" class="pg-btn" title="Trang cuối">&raquo;</a>
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

<!-- POP-UP THÊM PHIM -->
<div class="modal-backdrop ${openModal == 'add' ? 'open' : ''}" id="addPhimModal">
    <div class="modal-box modal-lg">
        <div class="modal-header">
            <h3>Thêm phim mới</h3>
            <button type="button" class="modal-close" onclick="closeModal('addPhimModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'add' and not empty error}">
            <div class="alert-error" id="addPhimError"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/phim/add" method="post">
            <div class="form-grid">
                <div class="form-group">
                    <label for="addMaPhim">Mã phim</label>
                    <input type="text" id="addMaPhim" name="maPhim" class="form-control"
                           value="Tự động sinh (Auto ID)" readonly style="background: var(--bg-input); cursor: not-allowed; color: var(--text-secondary);">
                </div>
                <div class="form-group">
                    <label for="addTenPhim">Tên phim<span class="required-star">*</span></label>
                    <input type="text" id="addTenPhim" name="tenPhim" class="form-control"
                           value="${openModal == 'add' ? formPhim.tenPhim : ''}"
                           placeholder="VD: Mai">
                </div>
                <div class="form-group">
                    <label for="addThoiLuong">Thời lượng (phút)<span class="required-star">*</span></label>
                    <input type="number" id="addThoiLuong" name="thoiLuong" class="form-control"
                           value="${openModal == 'add' ? formThoiLuong : ''}"
                           placeholder="VD: 120" min="1">
                </div>
                <div class="form-group">
                    <label for="addDoTuoi">Độ tuổi</label>
                    <select id="addDoTuoi" name="doTuoi" class="form-control">
                        <option value="P" ${openModal == 'add' && formPhim.doTuoi == 'P' ? 'selected' : ''}>P - Phổ biến mọi lứa tuổi</option>
                        <option value="K" ${openModal == 'add' && formPhim.doTuoi == 'K' ? 'selected' : ''}>K - Dưới 13 tuổi (có người giám hộ)</option>
                        <option value="T13" ${openModal == 'add' && formPhim.doTuoi == 'T13' ? 'selected' : ''}>T13 - Từ 13 tuổi trở lên</option>
                        <option value="T16" ${openModal == 'add' && formPhim.doTuoi == 'T16' ? 'selected' : ''}>T16 - Từ 16 tuổi trở lên</option>
                        <option value="T18" ${openModal == 'add' && formPhim.doTuoi == 'T18' ? 'selected' : ''}>T18 - Từ 18 tuổi trở lên</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="addQuocGia">Quốc gia</label>
                    <input type="text" id="addQuocGia" name="quocGia" class="form-control"
                           value="${openModal == 'add' ? formPhim.quocGia : ''}"
                           placeholder="VD: Việt Nam, Mỹ...">
                </div>
              
                <div class="form-group">
                    <label for="addNgayKhoiChieu">Ngày khởi chiếu<span class="required-star">*</span></label>
                    <input type="date" id="addNgayKhoiChieu" name="ngayKhoiChieu" class="form-control"
                           value="${openModal == 'add' ? formNgayKhoiChieu : ''}">
                </div>
                <div class="form-group">
                    <label for="addNgayKetThuc">Ngày kết thúc<span class="required-star">*</span></label>
                    <input type="date" id="addNgayKetThuc" name="ngayKetThuc" class="form-control"
                           value="${openModal == 'add' ? formNgayKetThuc : ''}">
                </div>
                <div class="form-group">
                    <label for="addDaoDien">Đạo diễn</label>
                    <input type="text" id="addDaoDien" name="daoDien" class="form-control"
                           value="${openModal == 'add' ? formPhim.daoDien : ''}"
                           placeholder="VD: Trấn Thành">
                </div>
                <div class="form-group">
                    <label for="addDienVien">Diễn viên</label>
                    <input type="text" id="addDienVien" name="dienVien" class="form-control"
                           value="${openModal == 'add' ? formPhim.dienVien : ''}"
                           placeholder="VD: Phương Anh Đào, Tuấn Trần">
                </div>
                <div class="form-group">
                    <label for="addPoster">Poster (tên ảnh / đường dẫn)</label>
                    <input type="text" id="addPoster" name="poster" class="form-control"
                           value="${openModal == 'add' ? formPhim.poster : ''}"
                           placeholder="VD: mai.jpg hoặc link URL">
                </div>
                <div class="form-group">
                    <label for="addTrailer">Trailer (video / YouTube URL)</label>
                    <input type="text" id="addTrailer" name="trailer" class="form-control"
                           value="${openModal == 'add' ? formPhim.trailer : ''}"
                           placeholder="VD: https://youtube.com/watch?v=...">
                </div>
                <div class="form-group full">
                    <label>Thể loại phim</label>
                    <div class="checkbox-group">
                        <c:forEach items="${listTheLoai}" var="tl">
                            <c:set var="tlChecked" value="false"/>
                            <c:if test="${openModal == 'add'}">
                                <c:forEach items="${formPhim.theLoais}" var="sel">
                                    <c:if test="${sel.maTheLoai == tl.maTheLoai}">
                                        <c:set var="tlChecked" value="true"/>
                                    </c:if>
                                </c:forEach>
                            </c:if>
                            <label class="checkbox-pill">
                                <input type="checkbox" name="maTheLoais" value="${tl.maTheLoai}" ${tlChecked ? 'checked' : ''}>
                                <span><c:out value="${tl.tenTheLoai}"/></span>
                            </label>
                        </c:forEach>
                    </div>
                </div>
                <div class="form-group full">
                    <label>Định dạng phim</label>
                    <div class="checkbox-group">
                        <c:forEach items="${listDinhDang}" var="dd">
                            <c:set var="ddChecked" value="false"/>
                            <c:if test="${openModal == 'add'}">
                                <c:forEach items="${formPhim.dinhDangs}" var="selDd">
                                    <c:if test="${selDd.maDinhDang == dd.maDinhDang}">
                                        <c:set var="ddChecked" value="true"/>
                                    </c:if>
                                </c:forEach>
                            </c:if>
                            <label class="checkbox-pill">
                                <input type="checkbox" name="maDinhDangs" value="${dd.maDinhDang}" ${ddChecked ? 'checked' : ''}>
                                <span><c:out value="${dd.tenDinhDang}"/></span>
                            </label>
                        </c:forEach>
                    </div>
                </div>
                <div class="form-group full">
                    <label for="addMoTa">Mô tả nội dung</label>
                    <textarea id="addMoTa" name="moTa" class="form-control"
                              placeholder="Tóm tắt nội dung phim..."><c:if test="${openModal == 'add'}"><c:out value="${formPhim.moTa}"/></c:if></textarea>
                </div>
            </div>
            <div style="font-size:12px; color:var(--text-secondary); margin-bottom:10px;">
                (<span class="required-star">*</span>) Trường bắt buộc nhập
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addPhimModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Thêm</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP SỬA PHIM -->
<div class="modal-backdrop ${openModal == 'update' ? 'open' : ''}" id="editPhimModal">
    <div class="modal-box modal-lg">
        <div class="modal-header">
            <h3>Sửa thông tin phim</h3>
            <button type="button" class="modal-close" onclick="closeModal('editPhimModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'update' and not empty error}">
            <div class="alert-error" id="editPhimError"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/phim/update" method="post">
            <div class="form-grid">
                <div class="form-group">
                    <label for="editMaPhim">Mã phim<span class="required-star">*</span></label>
                    <input type="text" id="editMaPhim" name="maPhim" class="form-control"
                           value="${openModal == 'update' ? formPhim.maPhim : ''}" readonly>
                </div>
                <div class="form-group">
                    <label for="editTenPhim">Tên phim<span class="required-star">*</span></label>
                    <input type="text" id="editTenPhim" name="tenPhim" class="form-control"
                           value="${openModal == 'update' ? formPhim.tenPhim : ''}">
                </div>
                <div class="form-group">
                    <label for="editThoiLuong">Thời lượng (phút)<span class="required-star">*</span></label>
                    <input type="number" id="editThoiLuong" name="thoiLuong" class="form-control"
                           value="${openModal == 'update' ? formThoiLuong : ''}" min="1">
                </div>
                <div class="form-group">
                    <label for="editDoTuoi">Độ tuổi</label>
                    <select id="editDoTuoi" name="doTuoi" class="form-control">
                        <option value="P" ${openModal == 'update' && formPhim.doTuoi == 'P' ? 'selected' : ''}>P - Phổ biến mọi lứa tuổi</option>
                        <option value="K" ${openModal == 'update' && formPhim.doTuoi == 'K' ? 'selected' : ''}>K - Dưới 13 tuổi (có người giám hộ)</option>
                        <option value="T13" ${openModal == 'update' && formPhim.doTuoi == 'T13' ? 'selected' : ''}>T13 - Từ 13 tuổi trở lên</option>
                        <option value="T16" ${openModal == 'update' && formPhim.doTuoi == 'T16' ? 'selected' : ''}>T16 - Từ 16 tuổi trở lên</option>
                        <option value="T18" ${openModal == 'update' && formPhim.doTuoi == 'T18' ? 'selected' : ''}>T18 - Từ 18 tuổi trở lên</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="editQuocGia">Quốc gia</label>
                    <input type="text" id="editQuocGia" name="quocGia" class="form-control"
                           value="${openModal == 'update' ? formPhim.quocGia : ''}"
                           placeholder="VD: Việt Nam, Mỹ...">
                </div>
                <div class="form-group">
                    <label for="editTrangThai">Trạng thái</label>
                    <select id="editTrangThai" name="trangThai" class="form-control">
                        <option value="Đang chiếu" ${openModal == 'update' && formPhim.trangThai == 'Đang chiếu' ? 'selected' : ''}>Đang chiếu</option>
                        <option value="Sắp chiếu" ${openModal == 'update' && formPhim.trangThai == 'Sắp chiếu' ? 'selected' : ''}>Sắp chiếu</option>
                        <option value="Ngừng chiếu" ${openModal == 'update' && formPhim.trangThai == 'Ngừng chiếu' ? 'selected' : ''}>Ngừng chiếu</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="editNgayKhoiChieu">Ngày khởi chiếu<span class="required-star">*</span></label>
                    <input type="date" id="editNgayKhoiChieu" name="ngayKhoiChieu" class="form-control"
                           value="${openModal == 'update' ? formNgayKhoiChieu : ''}">
                </div>
                <div class="form-group">
                    <label for="editNgayKetThuc">Ngày kết thúc<span class="required-star">*</span></label>
                    <input type="date" id="editNgayKetThuc" name="ngayKetThuc" class="form-control"
                           value="${openModal == 'update' ? formNgayKetThuc : ''}">
                </div>
                <div class="form-group">
                    <label for="editDaoDien">Đạo diễn</label>
                    <input type="text" id="editDaoDien" name="daoDien" class="form-control"
                           value="${openModal == 'update' ? formPhim.daoDien : ''}">
                </div>
                <div class="form-group">
                    <label for="editDienVien">Diễn viên</label>
                    <input type="text" id="editDienVien" name="dienVien" class="form-control"
                           value="${openModal == 'update' ? formPhim.dienVien : ''}">
                </div>
                <div class="form-group">
                    <label for="editPoster">Poster (tên ảnh / đường dẫn)</label>
                    <input type="text" id="editPoster" name="poster" class="form-control"
                           value="${openModal == 'update' ? formPhim.poster : ''}">
                </div>
                <div class="form-group">
                    <label for="editTrailer">Trailer (video / đường dẫn)</label>
                    <input type="text" id="editTrailer" name="trailer" class="form-control"
                           value="${openModal == 'update' ? formPhim.trailer : ''}">
                </div>
                <div class="form-group full">
                    <label>Thể loại phim</label>
                    <div class="checkbox-group">
                        <c:forEach items="${listTheLoai}" var="tl">
                            <c:set var="tlChecked" value="false"/>
                            <c:if test="${openModal == 'update'}">
                                <c:forEach items="${formPhim.theLoais}" var="sel">
                                    <c:if test="${sel.maTheLoai == tl.maTheLoai}">
                                        <c:set var="tlChecked" value="true"/>
                                    </c:if>
                                </c:forEach>
                            </c:if>
                            <label class="checkbox-pill">
                                <input type="checkbox" name="maTheLoais" value="${tl.maTheLoai}" ${tlChecked ? 'checked' : ''}>
                                <span><c:out value="${tl.tenTheLoai}"/></span>
                            </label>
                        </c:forEach>
                    </div>
                </div>
                <div class="form-group full">
                    <label>Định dạng phim</label>
                    <div class="checkbox-group">
                        <c:forEach items="${listDinhDang}" var="dd">
                            <c:set var="ddChecked" value="false"/>
                            <c:if test="${openModal == 'update'}">
                                <c:forEach items="${formPhim.dinhDangs}" var="selDd">
                                    <c:if test="${selDd.maDinhDang == dd.maDinhDang}">
                                        <c:set var="ddChecked" value="true"/>
                                    </c:if>
                                </c:forEach>
                            </c:if>
                            <label class="checkbox-pill">
                                <input type="checkbox" name="maDinhDangs" value="${dd.maDinhDang}" ${ddChecked ? 'checked' : ''}>
                                <span><c:out value="${dd.tenDinhDang}"/></span>
                            </label>
                        </c:forEach>
                    </div>
                </div>
                <div class="form-group full">
                    <label for="editMoTa">Mô tả nội dung</label>
                    <textarea id="editMoTa" name="moTa" class="form-control"><c:if test="${openModal == 'update'}"><c:out value="${formPhim.moTa}"/></c:if></textarea>
                </div>
            </div>
            <div style="font-size:12px; color:var(--text-secondary); margin-bottom:10px;">
                (<span class="required-star">*</span>) Trường bắt buộc nhập
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('editPhimModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Lưu cập nhật</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP CHI TIẾT PHIM -->
<div class="modal-backdrop" id="detailPhimModal" data-ctx="${pageContext.request.contextPath}">
    <div class="modal-box modal-lg">
        <div class="modal-header">
            <h3>Chi tiết phim</h3>
            <button type="button" class="modal-close" onclick="closeModal('detailPhimModal')">&times;</button>
        </div>
        <div class="form-grid">
            <div class="form-group">
                <label>Mã phim</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailMaPhim"></div>
            </div>
            <div class="form-group">
                <label>Tên phim</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailTenPhim"></div>
            </div>
            <div class="form-group full">
                <label>Thể loại</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailTheLoai"></div>
            </div>
            <div class="form-group full">
                <label>Định dạng</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailDinhDang"></div>
            </div>
            <div class="form-group">
                <label>Thời lượng</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailThoiLuong"></div>
            </div>
            <div class="form-group">
                <label>Độ tuổi</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailDoTuoi"></div>
            </div>
            <div class="form-group">
                <label>Quốc gia</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailQuocGia"></div>
            </div>
            <div class="form-group">
                <label>Trạng thái</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailTrangThai"></div>
            </div>
            <div class="form-group">
                <label>Ngày khởi chiếu</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailNgayKhoiChieu"></div>
            </div>
            <div class="form-group">
                <label>Ngày kết thúc</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailNgayKetThuc"></div>
            </div>
            <div class="form-group">
                <label>Đạo diễn</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailDaoDien"></div>
            </div>
            <div class="form-group">
                <label>Diễn viên</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailDienVien"></div>
            </div>
            <div class="form-group">
                <label>Poster</label>
                <div class="detail-media-box" id="detailPoster"></div>
            </div>
            <div class="form-group">
                <label>Trailer</label>
                <div class="detail-media-box" id="detailTrailer"></div>
            </div>
            <div class="form-group full">
                <label>Mô tả</label>
                <div class="form-control" style="background:var(--bg-input); min-height:60px;" id="detailMoTa"></div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-pink" onclick="closeModal('detailPhimModal')">Đóng</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=9"></script>
</body>
</html>
