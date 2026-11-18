<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%-- =========================================================================
     COMPONENT: CHỌN GHẾ NGỒI TRÊN SƠ ĐỒ KHÁN PHÒNG
     File: /ban-ve/chon_ghe.jsp
     ========================================================================= --%>

<div class="pos-section-block">
    <!-- Header thông tin phim và suất đang chọn -->
    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px dashed #e2e8f0; padding-bottom:12px; margin-bottom:14px;">
        <div>
            <div class="pos-step-heading">
                <span>CHỌN GHẾ NGỒI KHÁN PHÒNG</span>
            </div>
            <div style="font-size:13px; color:#64748b; margin-top:2px;">
                Phim: <strong><c:out value="${selectedPhim.tenPhim}"/></strong>
                | Suất: <strong style="color:#db2777;">${selectedSuat.gioBatDau.toString().substring(0, 5)}</strong> (${selectedNgay})
                | Phòng: <strong><c:out value="${selectedSuat.phongChieu.tenPhong}"/></strong> (${selectedSuat.dinhDang})
            </div>
        </div>
        <div>
            <button type="button" class="btn btn-ghost btn-sm" onclick="goToStep(1)">← Đổi phim / suất khác</button>
        </div>
    </div>

    <!-- Bảng chú thích các loại ghế -->
    <div class="seat-legend">
        <div class="legend-item">
            <span class="legend-box" style="background:#e2e8f0; border:1px solid #cbd5e1;"></span>
            <span>Thường (80k)</span>
        </div>
        <div class="legend-item">
            <span class="legend-box" style="background:#fef3c7; border:1.5px solid #f59e0b;"></span>
            <span>VIP (95k)</span>
        </div>
        <div class="legend-item">
            <span class="legend-box" style="background:#fce7f3; border:1.5px solid #ec4899; width:34px;"></span>
            <span>Ghế Đôi (120k)</span>
        </div>
        <div class="legend-item">
            <span class="legend-box" style="background:#db2777;"></span>
            <span>Đang chọn</span>
        </div>
        <div class="legend-item">
            <span class="legend-box" style="background:#1e293b; opacity:0.6;"></span>
            <span>Đã bán</span>
        </div>
    </div>

    <!-- Màn hình cong rạp chiếu (Screen) -->
    <div class="screen-wrap">
        <div class="cinema-screen-bar"></div>
        <div class="screen-text">MÀN HÌNH CHÍNH (SCREEN)</div>
    </div>

    <!-- Sơ đồ ghế khán phòng -->
    <c:choose>
        <c:when test="${empty mapHangGhe}">
            <div style="text-align:center; padding:40px; color:#64748b;">
                <p>Phòng chiếu này chưa có danh sách ghế. Vui lòng kiểm tra lại cấu hình phòng chiếu!</p>
            </div>
        </c:when>

        <c:otherwise>
            <div class="seats-container">
                <c:forEach items="${mapHangGhe}" var="row">
                    <div class="seat-row-pos">
                        <span class="row-name">${row.key}</span>

                        <c:forEach items="${row.value}" var="seat">
                            <c:set var="phuThu" value="${seat.loaiGhe != null && seat.loaiGhe.phuThu != null ? seat.loaiGhe.phuThu : 0}"/>
                            <c:set var="giaVeGhe" value="${selectedSuat.giaVeCoBan + phuThu}"/>
                            <c:set var="isSold" value="${bookedSeatIds.contains(seat.maGhe)}"/>
                            <c:set var="isBaoTri" value="${seat.trangThai == 'Bảo trì' || seat.trangThai == 'Hỏng'}"/>

                            <c:set var="typeClass" value="type-thuong"/>
                            <c:choose>
                                <c:when test="${seat.isGheDoi()}">
                                    <c:set var="typeClass" value="type-doi"/>
                                </c:when>
                                <c:when test="${seat.loaiGhe != null && seat.loaiGhe.maLoaiGhe == 2}">
                                    <c:set var="typeClass" value="type-vip"/>
                                </c:when>
                            </c:choose>

                            <div class="pos-seat ${typeClass} ${isSold ? 'sold' : ''} ${isBaoTri ? 'disabled' : ''}"
                                 data-maghe="${seat.maGhe}"
                                 data-tenghe="${seat.tenGhe}"
                                 data-loaighe="${seat.loaiGhe.tenLoaiGhe}"
                                 data-gia="${giaVeGhe}"
                                 title="Ghế ${seat.tenGhe} (${seat.loaiGhe.tenLoaiGhe}) - Giá: <fmt:formatNumber value='${giaVeGhe}' pattern='#,##0'/> đ ${isSold ? ' - [ĐÃ BÁN]' : ''}"
                                 onclick="toggleSeat(this)">
                                ${seat.tenGhe}
                            </div>
                        </c:forEach>

                        <span class="row-name">${row.key}</span>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- Nút chuyển bước -->
    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:20px; padding-top:14px; border-top:1px solid #e2e8f0;">
        <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${selectedNgay}&step=1" class="btn btn-outline btn-sm" style="text-decoration:none;">← Đổi phim / Suất chiếu khác</a>
        <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${selectedNgay}&maSuat=${selectedSuat.maSuat}&step=3" class="btn btn-pink" style="text-decoration:none;">Tiếp tục: Chọn Combo bắp nước →</a>
    </div>
</div>
