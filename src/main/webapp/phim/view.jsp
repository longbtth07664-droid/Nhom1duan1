<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách phim - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=10">
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

            <div class="nav-group open">
                <button type="button" class="nav-item nav-parent" onclick="toggleSubmenu(this)">
                    <span>Quản lí phim</span>
                    <span class="nav-arrow">▾</span>
                </button>
                <div class="nav-submenu">
                    <a href="${pageContext.request.contextPath}/phim/view" class="nav-subitem active">Danh sách phim</a>
                    <a href="${pageContext.request.contextPath}/the-loai/view" class="nav-subitem">Quản lí thể loại</a>
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
                <div class="user-avatar"><%= session.getAttribute("userName") != null ? session.getAttribute("userName").toString().substring(0, 1).toUpperCase() : "QL" %></div>
                <div class="user-info">
                    <div class="name"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Quản lý rạp" %></div>
                    <div class="role"><%= session.getAttribute("userRole") != null ? session.getAttribute("userRole") : "QuanLy" %></div>
                </div>
            </div>

            <a href="${pageContext.request.contextPath}/logout" class="role-switch-link" style="color: #ff4757; margin-top: 8px;">Đăng xuất</a>
        </div>
    </aside>

    <!-- NỘI DUNG DANH SÁCH PHIM -->
    <div class="main-wrapper">
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Danh sách phim</h2>
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
                        <div class="card-title">Danh sách phim</div>
                        <div class="card-subtitle">Quản lý thông tin, thể loại và lịch chiếu của các bộ phim tại rạp</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <button type="button" class="btn btn-pink" onclick="openAddPhim()">+ Thêm</button>
                        <span class="badge-pink">${listPhim.size()} phim</span>
                    </div>
                </div>

                <div class="movie-grid">
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
                                <div class="movie-meta">
                                    <div>Thời lượng: <strong>${item.thoiLuong} phút</strong></div>
                                    <div>Khởi chiếu: ${item.ngayKhoiChieu} - ${item.ngayKetThuc}</div>
                                    <c:if test="${not empty item.daoDien}">
                                        <div>Đạo diễn: <c:out value="${item.daoDien}"/></div>
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
                                        data-mota="<c:out value='${item.moTa}'/>"
                                        data-tentheloais="<c:out value='${item.tenTheLoaisStr}'/>"
                                        data-matheloais="<c:out value='${item.maTheLoaisStr}'/>"
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
                                        data-mota="<c:out value='${item.moTa}'/>"
                                        data-matheloais="<c:out value='${item.maTheLoaisStr}'/>"
                                        onclick="openEditPhimFromBtn(this)">Sửa</button>
                            </div>
                        </article>
                    </c:forEach>
                </div>
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
                    <label for="addMaPhim">Mã phim<span class="required-star">*</span></label>
                    <input type="text" id="addMaPhim" name="maPhim" class="form-control"
                           value="${openModal == 'add' ? formPhim.maPhim : ''}"
                           placeholder="VD: P11">
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
                           placeholder="VD: mai.jpg">
                </div>
                <div class="form-group">
                    <label for="addTrailer">Trailer (video / đường dẫn)</label>
                    <input type="text" id="addTrailer" name="trailer" class="form-control"
                           value="${openModal == 'add' ? formPhim.trailer : ''}"
                           placeholder="VD: trailer_p11.mp4">
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
            <div class="form-group">
                <label>Thời lượng</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailThoiLuong"></div>
            </div>
            <div class="form-group">
                <label>Độ tuổi</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailDoTuoi"></div>
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

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=7"></script>
</body>
</html>
