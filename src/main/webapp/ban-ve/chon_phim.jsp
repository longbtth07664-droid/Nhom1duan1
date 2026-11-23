<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- =========================================================================
     COMPONENT: CHỌN NGÀY & PHIM KÈM KHUNG GIỜ CHIẾU
     File: /ban-ve/chon_phim.jsp
     ========================================================================= --%>

<!-- 1. CHỌN NGÀY CHIẾU -->
<div class="pos-section-block">
    <div class="pos-step-heading">
        <span>1. CHỌN NGÀY CHIẾU</span>
    </div>

    <div class="date-strip-compact">
        <c:forEach items="${dateTabs}" var="tab">
            <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${tab.dateValue}"
               class="date-pill-pos ${tab.active ? 'active' : ''}">
                <span class="day-title">${tab.dayLabel}</span>
                <span class="date-text">${tab.dateDisplay}</span>
            </a>
        </c:forEach>

        <!-- Input chọn ngày mở rộng -->
        <form action="${pageContext.request.contextPath}/ban-ve" method="get" style="display:flex; align-items:center; margin-left: 6px;">
            <input type="date" name="ngayChieu" class="form-control" style="width: 130px; height: 42px; font-weight:600; font-size:12px;"
                   value="${selectedNgay}" onchange="this.form.submit()">
        </form>
    </div>
</div>

<!-- 2. CHỌN PHIM & KHUNG GIỜ CHIẾU -->
<div class="pos-section-block" style="margin-top: 18px;">
    <div class="pos-step-heading-bar">
        <div class="pos-step-heading">
            <span>2. CHỌN PHIM & KHUNG GIỜ CHIẾU</span>
        </div>

        <!-- Ô tìm tên phim nhanh -->
        <form action="${pageContext.request.contextPath}/ban-ve" method="get" class="search-box-compact">
            <input type="hidden" name="ngayChieu" value="${selectedNgay}">
            <input type="text" name="keyword" class="search-input-pos"
                   placeholder="🔍 Tìm tên phim nhanh..." value="<c:out value='${keyword}'/>">
        </form>
    </div>

    <!-- Danh sách phim có suất chiếu trong ngày -->
    <c:choose>
        <c:when test="${empty movieSchedules}">
            <div class="no-movie-box">
                <div style="font-size: 32px; margin-bottom: 8px;">🎬</div>
                <h4 style="margin: 0 0 6px 0; color: #9f1239; font-size: 15px;">Hôm nay chưa có phim nào có lịch chiếu!</h4>
                <p style="color: #64748b; font-size: 13px; margin: 0 auto 12px auto;">
                    Không tìm thấy suất chiếu nào vào ngày <strong>${selectedNgay}</strong>. Vui lòng chọn ngày chiếu khác ở thanh ngày bên trên.
                </p>
            </div>
        </c:when>

        <c:otherwise>
            <div class="movie-schedule-list">
                <c:forEach items="${movieSchedules}" var="item">
                    <c:set var="m" value="${item.phim}"/>
                    <c:set var="isMovieActive" value="${not empty selectedPhim && selectedPhim.maPhim == m.maPhim}"/>

                    <!-- Thẻ phim ngang -->
                    <article class="movie-schedule-card ${isMovieActive ? 'selected' : ''}">
                        <!-- Poster phim bên trái -->
                        <div class="card-poster-wrap">
                            <c:choose>
                                <c:when test="${not empty m.poster && (m.poster.startsWith('http://') or m.poster.startsWith('https://'))}">
                                    <img src="<c:out value='${m.poster}'/>" class="card-poster-img" alt="poster" onerror="this.style.display='none'">
                                </c:when>
                                <c:when test="${not empty m.poster}">
                                    <img src="${pageContext.request.contextPath}/assets/images/<c:out value='${m.poster}'/>" class="card-poster-img" alt="poster" onerror="this.style.display='none'">
                                </c:when>
                                <c:otherwise>
                                    <div class="card-poster-fallback">
                                        <span>POSTER</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Chi tiết phim và các suất chiếu bên phải -->
                        <div class="card-content-wrap">
                            <!-- Dòng tiêu đề phim và nhãn độ tuổi -->
                            <div class="card-title-row">
                                <h3 class="movie-name-heading">
                                    <c:out value="${m.tenPhim}"/>
                                    <span class="badge-age-pos"><c:out value="${not empty m.doTuoi ? m.doTuoi : 'T16'}"/></span>
                                </h3>

                                <c:if test="${isMovieActive}">
                                    <span class="badge-selected-status">✓ Đang chọn</span>
                                </c:if>
                            </div>

                            <!-- Thông tin phụ: Thể loại • Thời lượng • Quốc gia -->
                            <div class="movie-meta-text">
                                <c:choose>
                                    <c:when test="${not empty m.tenTheLoaisStr}">
                                        <c:out value="${m.tenTheLoaisStr}"/>
                                    </c:when>
                                    <c:otherwise>Hành Động, Phiêu Lưu</c:otherwise>
                                </c:choose>
                                • ${m.thoiLuong} phút
                                <c:if test="${not empty m.quocGia}">
                                    • <c:out value="${m.quocGia}"/>
                                </c:if>
                            </div>

                            <!-- Khu vực các nút bấm Suất Chiếu trực tiếp -->
                            <div class="showtimes-section">
                                <div class="showtimes-section-title">CHỌN SUẤT CHIẾU TRONG NGÀY:</div>
                                <div class="showtime-pills-row">
                                    <c:forEach items="${item.suatChieus}" var="sc">
                                        <c:set var="isSuatActive" value="${not empty selectedSuat && selectedSuat.maSuat == sc.maSuat}"/>

                                        <c:choose>
                                            <%-- Nếu suất chiếu đã qua giờ bắt đầu: không cho phép bán vé nữa --%>
                                            <c:when test="${sc.quaGio}">
                                                <span class="showtime-btn-pill" style="opacity: 0.5; background: #f1f5f9; border-color: #cbd5e1; cursor: not-allowed; color: #94a3b8;"
                                                      title="Suất chiếu đã bắt đầu/qua giờ, hệ thống đã đóng bán vé!">
                                                    <strong style="text-decoration: line-through;">${sc.gioBatDau.toString().substring(0, 5)}</strong>
                                                    <span class="sc-room" style="color: #ef4444; font-size: 10px; font-weight: 700;">• Đã chiếu</span>
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <!-- Suất chiếu hợp lệ, bấm vào để chuyển sang bước chọn ghế -->
                                                <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${selectedNgay}&maSuat=${sc.maSuat}&step=2"
                                                   class="showtime-btn-pill ${isSuatActive ? 'active' : ''}"
                                                   title="Phòng: ${sc.phongChieu.tenPhong} - Định dạng: ${sc.dinhDang}">
                                                    <strong>${sc.gioBatDau.toString().substring(0, 5)}</strong>
                                                    <span class="sc-room">
                                                        • <c:choose>
                                                            <c:when test="${sc.dinhDang == 'IMAX' || sc.phongChieu.maPhong == '4'}">IMAX</c:when>
                                                            <c:otherwise>P.0<c:out value="${sc.phongChieu.maPhong}"/></c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </article>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>
