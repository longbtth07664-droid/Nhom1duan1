<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quầy Bán Vé (POS) - Rạp Chiếu Phim CINEMAX</title>
    <!-- CSS giao diện hệ thống chung -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=13">
    <!-- CSS riêng cho module Bán vé POS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/ban-ve.css?v=4">
</head>
<body>
<div class="app-shell">
    <!-- 1. MENU ĐIỀU HƯỚNG BÊN TRÁI (TỰ ĐỘNG THEO QUYỀN QUẢN LÝ / NHÂN VIÊN) -->
    <c:choose>
        <c:when test="${sessionScope.userRole == 'NhanVien'}">
            <jsp:include page="/menunv.jsp" />
        </c:when>
        <c:otherwise>
            <jsp:include page="/menuadmin.jsp" />
        </c:otherwise>
    </c:choose>

    <!-- 2. NỘI DUNG CHÍNH CỦA TRANG -->
    <div class="main-wrapper" style="background:#f8fafc;">
        <!-- Topbar tối màu chuẩn phong cách rạp phim POS -->
        <header class="topbar-pos-dark">
            <div class="pos-shift-info">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()" style="color:#ffffff;">☰</button>
                <span>
                    Ca làm việc: <strong>Sáng</strong> • Thu ngân:
                    <strong><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Trần Văn Quản" %></strong>
                    (<%= session.getAttribute("userRole") != null ? session.getAttribute("userRole") : "QL" %>)
                </span>
            </div>

            <!-- Stepper 3 bước ở góc trên bên phải -->
            <div class="pos-stepper-dark">
                <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${selectedNgay}&step=1"
                   class="step-pill-btn ${currentStep == 1 ? 'active' : ''}">
                    1. Phim & Suất chiếu
                </a>

                <c:choose>
                    <c:when test="${not empty selectedSuat}">
                        <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${selectedNgay}&maSuat=${selectedSuat.maSuat}&step=2"
                           class="step-pill-btn ${currentStep == 2 ? 'active' : ''}">
                            2. Chọn ghế
                        </a>
                        <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${selectedNgay}&maSuat=${selectedSuat.maSuat}&step=3"
                           class="step-pill-btn ${currentStep == 3 ? 'active' : ''}">
                            3. Chọn Combo
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="step-pill-btn disabled">2. Chọn ghế</span>
                        <span class="step-pill-btn disabled">3. Chọn Combo</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </header>

        <main class="content-area" style="padding: 16px 20px;">
            <!-- BỐ CỤC 2 CỘT: CỘT THAO TÁC BÊN TRÁI & CHI TIẾT HÓA ĐƠN BÊN PHẢI -->
            <div class="pos-container">
                <!-- CỘT TRÁI: HIỂN THỊ TỪNG BƯỚC THEO JSP RIÊNG BIỆT (KHÔNG DÙNG STEP1/2) -->
                <section class="pos-main-col">
                    <c:choose>
                        <c:when test="${currentStep == 1}">
                            <jsp:include page="/ban-ve/chon_phim.jsp" />
                        </c:when>

                        <c:when test="${currentStep == 2}">
                            <jsp:include page="/ban-ve/chon_ghe.jsp" />
                        </c:when>

                        <c:when test="${currentStep == 3}">
                            <jsp:include page="/ban-ve/chon_combo.jsp" />
                        </c:when>

                        <c:otherwise>
                            <jsp:include page="/ban-ve/chon_phim.jsp" />
                        </c:otherwise>
                    </c:choose>
                </section>

                <!-- CỘT PHẢI: CHI TIẾT HÓA ĐƠN DÙNG CHUNG -->
                <jsp:include page="/ban-ve/chi_tiet_hoa_don.jsp" />
            </div>
        </main>
    </div>
</div>

<!-- Scripts xử lý JavaScript -->
<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=13"></script>
<script src="${pageContext.request.contextPath}/assets/js/ban-ve.js?v=4"></script>
</body>
</html>
