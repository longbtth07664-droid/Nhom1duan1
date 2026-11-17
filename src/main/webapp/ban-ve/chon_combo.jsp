<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%-- =========================================================================
     COMPONENT: CHỌN COMBO BẮP NƯỚC (F&B)
     File: /ban-ve/chon_combo.jsp
     ========================================================================= --%>

<div class="pos-section-block">
    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px dashed #e2e8f0; padding-bottom:12px; margin-bottom:14px;">
        <div>
            <div class="pos-step-heading">
                <span>CHỌN COMBO BẮP NƯỚC (F&B)</span>
            </div>
            <div style="font-size:13px; color:#64748b; margin-top:2px;">
                Bấm dấu cộng (+) để thêm combo bắp nước theo yêu cầu của khách hàng
            </div>
        </div>
        <div>
            <button type="button" class="btn btn-ghost btn-sm" onclick="goToStep(2)">← Quay lại đổi ghế</button>
        </div>
    </div>

    <!-- Danh sách các gói Combo -->
    <c:choose>
        <c:when test="${empty listCombo}">
            <div style="text-align:center; padding:40px; color:#64748b;">
                <p>Hiện không có gói Combo nào đang mở bán.</p>
            </div>
        </c:when>

        <c:otherwise>
            <div class="combo-grid">
                <c:forEach items="${listCombo}" var="c">
                    <div class="combo-card">
                        <div class="combo-info">
                            <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                                <h4><c:out value="${c.tenCombo}"/></h4>
                                <span class="badge-pink" style="font-size:10px; padding:2px 6px;">Hot</span>
                            </div>
                            <p><c:out value="${not empty c.moTa ? c.moTa : '1 Bắp lớn thơm ngon + 2 Nước ngọt mát lạnh'}"/></p>
                        </div>

                        <div class="combo-footer">
                            <div class="combo-price">
                                <fmt:formatNumber value="${c.giaCombo}" pattern="#,##0"/> đ
                            </div>

                            <!-- Nút tăng / giảm số lượng combo (+ / -) -->
                            <div class="counter-control">
                                <button type="button" class="counter-btn"
                                        onclick="changeComboQty('${c.maCombo}', '<c:out value="${c.tenCombo}"/>', ${c.giaCombo}, -1)">-</button>
                                <span class="counter-val" id="combo-qty-${c.maCombo}">0</span>
                                <button type="button" class="counter-btn"
                                        onclick="changeComboQty('${c.maCombo}', '<c:out value="${c.tenCombo}"/>', ${c.giaCombo}, 1)">+</button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- Nút hoàn tất đơn -->
    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:24px; padding-top:16px; border-top:1px solid #e2e8f0;">
        <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${selectedNgay}&maSuat=${selectedSuat.maSuat}&step=2" class="btn btn-outline btn-sm" style="text-decoration:none;">← Quay lại chọn ghế ngồi</a>
        <a href="${pageContext.request.contextPath}/thanh-toan?ngayChieu=${selectedNgay}&maSuat=${selectedSuat.maSuat}" class="btn btn-pink" style="text-decoration:none;">
            ✓ Xác nhận đơn & Chuyển sang thanh toán
        </a>
    </div>
</div>
