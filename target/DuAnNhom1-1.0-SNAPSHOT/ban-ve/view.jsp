<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quầy Bán Vé - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=10">
    <style>
        /* 1. Date Selector Pills */
        .date-strip {
            display: flex;
            align-items: center;
            gap: 10px;
            overflow-x: auto;
            padding: 4px 2px 14px 2px;
            margin-bottom: 12px;
        }
        .date-pill {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-width: 90px;
            padding: 10px 14px;
            background: var(--bg-card, #ffffff);
            border: 1px solid var(--border-subtle, #e2e8f0);
            border-radius: var(--radius-md, 10px);
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
            color: var(--text-primary, #0f172a);
        }
        .date-pill:hover {
            border-color: var(--primary, #db2777);
            transform: translateY(-2px);
        }
        .date-pill.active {
            background: linear-gradient(135deg, #db2777 0%, #f43f5e 100%);
            border-color: #db2777;
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(219, 39, 119, 0.35);
        }
        .date-pill .day-label {
            font-size: 12px;
            font-weight: 500;
            opacity: 0.85;
            margin-bottom: 2px;
        }
        .date-pill .date-num {
            font-size: 15px;
            font-weight: 700;
        }

        /* 2. Interactive Movie Selection Cards */
        .pos-movie-card {
            position: relative;
            cursor: pointer;
            border: 2px solid transparent;
            transition: all 0.25s ease;
        }
        .pos-movie-card:hover {
            border-color: #fbcfe8;
            transform: translateY(-3px);
            box-shadow: 0 10px 24px rgba(0, 0, 0, 0.08);
        }
        .pos-movie-card.selected {
            border-color: #db2777 !important;
            box-shadow: 0 0 0 3px rgba(219, 39, 119, 0.2), 0 10px 24px rgba(219, 39, 119, 0.15);
            background: #fffdfd;
        }
        .selected-badge-flag {
            position: absolute;
            top: 10px;
            right: 10px;
            background: #db2777;
            color: #ffffff;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 99px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.2);
            z-index: 3;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        /* 3. Selected Movie Banner & Placeholder */
        .selection-panel {
            background: #ffffff;
            border: 1px solid var(--border-subtle, #e2e8f0);
            border-radius: var(--radius-lg, 14px);
            padding: 20px 24px;
            margin-top: 24px;
            box-shadow: var(--shadow-sm, 0 2px 8px rgba(0,0,0,0.04));
        }
        .selection-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px dashed var(--border-subtle, #e2e8f0);
            padding-bottom: 14px;
            margin-bottom: 16px;
        }
        .selection-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--text-primary, #0f172a);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .movie-mini-preview {
            display: flex;
            gap: 16px;
            align-items: center;
        }
        .mini-poster {
            width: 60px;
            height: 85px;
            border-radius: 8px;
            object-fit: cover;
            background: #f1f5f9;
            border: 1px solid #e2e8f0;
        }
        .mini-info h4 {
            margin: 0 0 4px 0;
            font-size: 16px;
            color: var(--text-primary, #0f172a);
        }
        .mini-info p {
            margin: 2px 0;
            font-size: 13px;
            color: var(--text-secondary, #64748b);
        }
        .step-placeholder-box {
            background: #f8fafc;
            border: 2px dashed #cbd5e1;
            border-radius: 12px;
            padding: 30px;
            text-align: center;
            margin-top: 16px;
        }
        .step-placeholder-box .icon {
            font-size: 32px;
            margin-bottom: 8px;
        }
        .step-placeholder-box h5 {
            font-size: 15px;
            font-weight: 700;
            color: #334155;
            margin: 0 0 6px 0;
        }
        .step-placeholder-box p {
            font-size: 13px;
            color: #64748b;
            max-width: 500px;
            margin: 0 auto;
        }
    </style>
</head>
<body>
<div class="app-shell">
    <!-- MENU BÊN TRÁI: Dùng chung menu của Quản lý hoặc Nhân viên -->

            <jsp:include page="/menuadmin.jsp" />

    NỘI DUNG CHÍNH -->

    <!-- <div class="main-wrapper">
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Quầy Bán Vé</h2>
                </div>
            </div>
            <div class="topbar-right">
                <span class="badge-pink" style="padding: 6px 12px; font-size: 13px;">Ngày chiếu: ${selectedNgay}</span>
            </div>
        </header>

        <main class="content-area">
            <!-- 1. BƯỚC 1: THANH CHỌN NGÀY CHIẾU (DATE TABS) -->
            <div class="card" style="margin-bottom: 20px;">
                <div class="card-header" style="margin-bottom: 10px;">
                    <div>
                        <div class="card-title">Bước 1: Chọn ngày chiếu</div>
                        <div class="card-subtitle">Khách hàng muốn mua vé xem phim cho ngày nào?</div>
                    </div>
                </div>

                <div class="date-strip">
                    <c:forEach items="${dateTabs}" var="tab">
                        <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${tab.dateValue}&keyword=<c:out value='${keyword}'/>&maTheLoai=<c:out value='${selectedTheLoai}'/>"
                           class="date-pill ${tab.active ? 'active' : ''}">
                            <span class="day-label">${tab.dayLabel}</span>
                            <span class="date-num">${tab.dateDisplay}</span>
                        </a>
                    </c:forEach>

                    <!-- Chọn ngày tùy ý bằng input date -->
                    <form action="${pageContext.request.contextPath}/ban-ve" method="get" style="display:flex; align-items:center; margin-left: 8px;">
                        <input type="hidden" name="keyword" value="<c:out value='${keyword}'/>">
                        <input type="hidden" name="maTheLoai" value="<c:out value='${selectedTheLoai}'/>">
                        <input type="date" name="ngayChieu" class="form-control" style="width: 140px; height: 42px;"
                               value="${selectedNgay}" onchange="this.form.submit()">
                    </form>
                </div>
            </div>

            <!-- 2. BƯỚC 2: TÌM KIẾM & CHỌN PHIM -->
            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Bước 2: Chọn phim</div>
                        <div class="card-subtitle">Click vào một bộ phim bên dưới để chọn</div>
                    </div>
                    <div>
                        <span class="badge-pink">${listPhim.size()} phim khả dụng</span>
                    </div>
                </div>

                <!-- Bộ lọc nhanh -->
                <form action="${pageContext.request.contextPath}/ban-ve" method="get" class="filter-bar" style="display:flex; flex-wrap:wrap; gap:12px; align-items:center; margin-bottom: 20px;">
                    <input type="hidden" name="ngayChieu" value="${selectedNgay}">
                    <c:if test="${not empty selectedPhim}">
                        <input type="hidden" name="maPhim" value="${selectedPhim.maPhim}">
                    </c:if>

                    <input type="text" name="keyword" class="form-control" style="max-width: 320px;"
                           placeholder="Tìm kiếm tên phim, đạo diễn..." value="<c:out value='${keyword}'/>">

                    <select name="maTheLoai" class="form-control" style="max-width: 220px;">
                        <option value="" ${empty selectedTheLoai || selectedTheLoai == 'Tất cả' ? 'selected' : ''}>-- Tất cả thể loại --</option>
                        <c:forEach items="${listTheLoai}" var="tl">
                            <option value="${tl.maTheLoai}" ${selectedTheLoai == tl.maTheLoai.toString() ? 'selected' : ''}>
                                <c:out value="${tl.tenTheLoai}"/>
                            </option>
                        </c:forEach>
                    </select>

                    <button type="submit" class="btn btn-pink">Lọc phim</button>
                    <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${selectedNgay}" class="btn btn-ghost">Làm mới</a>
                </form>

                <!-- Grid danh sách phim -->
                <div class="movie-grid">
                    <c:if test="${empty listPhim}">
                        <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: var(--text-secondary);">
                            <p style="font-size: 16px; margin-bottom: 8px;">Không tìm thấy phim nào phù hợp!</p>
                            <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${selectedNgay}" class="btn btn-ghost btn-sm">Xem tất cả phim</a>
                        </div>
                    </c:if>

                    <c:forEach items="${listPhim}" var="item">
                        <c:set var="isSelected" value="${not empty selectedPhim && selectedPhim.maPhim == item.maPhim}"/>
                        <article class="movie-card pos-movie-card ${isSelected ? 'selected' : ''}"
                                 onclick="chonPhim('${item.maPhim}')">

                            <c:if test="${isSelected}">
                                <div class="selected-badge-flag">✓ Đang chọn</div>
                            </c:if>

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
                                    <c:if test="${not empty item.quocGia}">
                                        <div>Quốc gia: <c:out value="${item.quocGia}"/></div>
                                    </c:if>
                                    <div>Trạng thái:
                                        <span style="display:inline-block; font-size:11px; font-weight:600; padding:2px 8px; border-radius:4px; background: ${item.trangThai == 'Đang chiếu' ? '#dcfce7; color:#15803d;' : (item.trangThai == 'Sắp chiếu' ? '#fef9c3; color:#a16207;' : '#f1f5f9; color:#475569;')}">
                                            <c:out value="${item.trangThai}"/>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="movie-actions">
                                <button type="button" class="btn ${isSelected ? 'btn-pink' : 'btn-outline'} btn-sm" style="width: 100%;">
                                    ${isSelected ? 'Đang chọn phim này' : 'Chọn phim'}
                                </button>
                            </div>
                        </article>
                    </c:forEach>
                </div>

                <!-- 3. BƯỚC TIẾP THEO: THÔNG TIN PHIM ĐÃ CHỌN & CHỜ SUẤT CHIẾU / GHẾ -->
                <div class="selection-panel">
                    <div class="selection-header">
                        <div class="selection-title">
                            <span>🎬</span> Phim đang được chọn
                        </div>
                        <c:if test="${not empty selectedPhim}">
                            <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${selectedNgay}" class="btn btn-ghost btn-sm" style="color: #ef4444;">Bỏ chọn</a>
                        </c:if>
                    </div>

                    <c:choose>
                        <c:when test="${not empty selectedPhim}">
                            <div class="movie-mini-preview">
                                <c:choose>
                                    <c:when test="${not empty selectedPhim.poster && (selectedPhim.poster.startsWith('http://') or selectedPhim.poster.startsWith('https://'))}">
                                        <img src="<c:out value='${selectedPhim.poster}'/>" class="mini-poster" alt="poster">
                                    </c:when>
                                    <c:when test="${not empty selectedPhim.poster}">
                                        <img src="${pageContext.request.contextPath}/assets/images/<c:out value='${selectedPhim.poster}'/>" class="mini-poster" alt="poster">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="mini-poster" style="display:flex;align-items:center;justify-content:center;font-size:10px;color:#94a3b8;">NO IMG</div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="mini-info">
                                    <h4><c:out value="${selectedPhim.tenPhim}"/></h4>
                                    <p><strong>Thể loại:</strong> <c:out value="${selectedPhim.tenTheLoaisStr}"/></p>
                                    <p><strong>Thời lượng:</strong> ${selectedPhim.thoiLuong} phút | <strong>Độ tuổi:</strong> <c:out value="${selectedPhim.doTuoi}"/></p>
                                    <p><strong>Ngày chiếu đã chọn:</strong> <span style="color:#db2777; font-weight:700;">${selectedNgay}</span></p>
                                </div>
                            </div>

                            <!-- Placeholder đón Suất chiếu và Ghế -->
                            <div class="step-placeholder-box">
                                <div class="icon">🎟️</div>
                                <h5>Bước tiếp theo: Chọn Suất Chiếu & Sơ Đồ Ghế</h5>
                                <p>
                                    Bạn đã chọn thành công phim <strong>"<c:out value="${selectedPhim.tenPhim}"/>"</strong>.
                                    Khu vực này đã sẵn sàng để tích hợp Suất chiếu và Sơ đồ ghế ngay khi nhóm của bạn hoàn thành phân hệ quản lý ghế!
                                </p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div style="text-align: center; padding: 24px; color: var(--text-secondary);">
                                <p style="font-size: 14px; margin: 0;">👉 Vui lòng click chọn một bộ phim ở danh sách trên để tiếp tục bước bán vé.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </main>
    </div>
</div>

<script>
    // Hàm chuyển hướng chọn phim giữ nguyên ngày chiếu hiện tại
    function chonPhim(maPhim) {
        const urlParams = new URLSearchParams(window.location.search);
        urlParams.set('maPhim', maPhim);
        window.location.href = '${pageContext.request.contextPath}/ban-ve?' + urlParams.toString();
    }
</script>
</body>
</html>
