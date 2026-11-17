<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%-- =========================================================================
     COMPONENT: CỘT PHẢI - CHI TIẾT HÓA ĐƠN (GIỎ VÉ POS)
     File: /ban-ve/chi_tiet_hoa_don.jsp
     ========================================================================= --%>

<aside class="pos-cart-panel" id="posMiniCart" data-base-price="${not empty selectedSuat ? selectedSuat.giaVeCoBan : 0}">
    <!-- Tiêu đề cột -->
    <div class="cart-title-top">
        CHI TIẾT HÓA ĐƠN
    </div>

    <!-- Thông tin Phim & Suất chiếu -->
    <c:choose>
        <c:when test="${not empty selectedPhim}">
            <div class="cart-movie-highlight">
                <h2 class="cart-movie-name"><c:out value="${selectedPhim.tenPhim}"/></h2>

                <c:choose>
                    <c:when test="${not empty selectedSuat}">
                        <div class="cart-sub-meta">
                            Suất: <strong>${selectedSuat.gioBatDau.toString().substring(0, 5)}</strong>
                            • Ngày: <strong>${selectedNgay}</strong>
                        </div>
                        <div class="cart-sub-meta">
                            Phòng: <strong><c:out value="${selectedSuat.phongChieu.tenPhong}"/></strong> (${selectedSuat.dinhDang})
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="cart-sub-meta" style="color:#e11d48; font-style:italic;">
                            ⚠️ Chưa chọn khung giờ suất chiếu
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:when>

        <c:otherwise>
            <div class="cart-movie-highlight" style="text-align:center; padding:16px 0; color:#94a3b8; font-style:italic;">
                Chưa chọn bộ phim nào
            </div>
        </c:otherwise>
    </c:choose>

    <!-- Khu vực hiển thị Ghế đã chọn -->
    <div class="cart-info-block">
        <div class="cart-line-row">
            <span class="label-light">Ghế đã chọn:</span>
            <span class="value-bold text-pink" id="cartSeatNamesText">Chưa chọn</span>
        </div>
        <div class="cart-line-row">
            <span class="label-light" id="cartSeatCountLabel">Tiền vé (0 vé):</span>
            <span class="value-bold" id="cartSeatTotalText">0 đ</span>
        </div>
    </div>

    <!-- Khu vực hiển thị Combo đã chọn -->
    <div class="cart-info-block" id="cartCombosSection" style="padding-top:10px; border-top:1px dashed #e2e8f0;">
        <div id="cartCombosList">
            <div style="color:#94a3b8; font-size:12px; font-style:italic;">Chưa chọn combo bắp nước</div>
        </div>
    </div>

    <!-- Tổng thanh toán to đậm -->
    <div class="cart-grand-total-wrap">
        <div class="total-row-main">
            <span class="total-title">TỔNG THANH TOÁN:</span>
            <span class="total-value" id="cartTotalAmount">0 đ</span>
        </div>
        <div class="total-vat-note">(Đã bao gồm thuế GTGT/VAT)</div>

        <!-- Các nút bấm chuyển bước -->
        <div class="cart-button-group">
            <c:choose>
                <c:when test="${currentStep == 1}">
                    <button type="button" class="btn-pos-action" disabled style="opacity:0.6; cursor:not-allowed;">
                        👉 Hãy click vào một khung giờ chiếu để chọn ghế
                    </button>
                </c:when>

                <c:when test="${currentStep == 2}">
                    <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${selectedNgay}&maSuat=${selectedSuat.maSuat}&step=3"
                       class="btn-pos-action" style="text-align:center; text-decoration:none; display:block;">
                        Tiếp tục: Chọn Combo bắp nước →
                    </a>
                </c:when>

                <c:when test="${currentStep == 3}">
                    <button type="button" class="btn-pos-action" onclick="alert('Đã sẵn sàng chuyển sang màn hình Thanh toán & In vé!')">
                        ✓ Xác nhận đơn & Thu tiền
                    </button>
                </c:when>
            </c:choose>

            <button type="button" class="btn-pos-reset"
                    onclick="resetBooking('${pageContext.request.contextPath}', '${selectedNgay}')">
                ↺ Làm mới đơn
            </button>
        </div>
    </div>
</aside>
