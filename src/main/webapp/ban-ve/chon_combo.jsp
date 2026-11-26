<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%-- =========================================================================
     COMPONENT: CHỌN COMBO & SẢN PHẨM BẮP NƯỚC BÁN LẺ (F&B)
     File: /ban-ve/chon_combo.jsp
     ========================================================================= --%>

<div class="pos-section-block">
    <!-- Hàng tiêu đề + Thanh tìm kiếm nhanh -->
    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px dashed #e2e8f0; padding-bottom:12px; margin-bottom:18px; flex-wrap:wrap; gap:12px;">
        <div>
            <div class="pos-step-heading">
                <span>3. CHỌN BẮP NƯỚC & COMBO (F&B)</span>
            </div>
            <div style="font-size:13px; color:#64748b; margin-top:2px;">
                Bấm dấu cộng (+) để thêm combo tiết kiệm hoặc các món bắp, nước bán lẻ cho khách
            </div>
        </div>

        <div style="display:flex; align-items:center; gap:10px; flex:1; justify-content:flex-end; min-width:280px;">
            <!-- Thanh tìm kiếm nhanh sản phẩm & combo -->
            <div style="position:relative; width:100%; max-width:320px;">
                <input type="text" id="fnbSearchInput" class="form-control"
                       placeholder="🔍 Tìm nhanh combo, bắp, nước..."
                       oninput="searchFnbItems(this.value)"
                       style="height:38px; border-radius:20px; padding:0 14px 0 36px; font-size:13px; background:#ffffff; border:1px solid #cbd5e1; box-shadow: 0 1px 3px rgba(0,0,0,0.04);">
                <span style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:#94a3b8; font-size:14px; pointer-events:none;">🔍</span>
            </div>
            <button type="button" class="btn btn-ghost btn-sm" onclick="goToStep(2)">← Quay lại đổi ghế</button>
        </div>
    </div>

    <!-- Thông báo khi tìm kiếm không ra kết quả -->
    <div id="fnbNoResultMsg" style="display:none; text-align:center; padding:36px 20px; color:#64748b; background:#ffffff; border-radius:12px; border:1px dashed #cbd5e1; margin-bottom:20px;">
        <div style="font-size:32px; margin-bottom:8px;">🔍</div>
        <div style="font-size:15px; font-weight:700; color:#334155; margin-bottom:4px;">Không tìm thấy món hoặc combo nào phù hợp!</div>
        <div style="font-size:13px; color:#94a3b8;">Vui lòng thử tìm với từ khóa khác (ví dụ: bắp, nước, pepsi, caramel...)</div>
    </div>

    <!-- 1. KHU VỰC GÓI COMBO -->
    <div id="sectionCombos" style="margin-bottom: 24px;">
        <div style="display:flex; align-items:center; gap:8px; margin-bottom:12px;">
            <span style="font-size:16px;">🍿</span>
            <h4 style="margin:0; font-size:14px; font-weight:800; color:#0f172a; text-transform:uppercase; letter-spacing:0.5px;">Gói Combo Ưu Đãi</h4>
            <span style="font-size:11px; background:#fce7f3; color:#db2777; padding:2px 8px; border-radius:10px; font-weight:700;">Tiết kiệm hơn</span>
        </div>

        <c:choose>
            <c:when test="${empty listCombo}">
                <div style="text-align:center; padding:24px; color:#94a3b8; background:#ffffff; border-radius:10px; border:1px dashed #e2e8f0;">
                    <p style="margin:0;">Hiện không có gói Combo nào đang mở bán.</p>
                </div>
            </c:when>

            <c:otherwise>
                <div class="combo-grid">
                    <c:forEach items="${listCombo}" var="c">
                        <div class="combo-card is-combo-item" data-search="<c:out value='${c.tenCombo} ${c.moTa} combo'/>">
                            <div class="combo-info">
                                <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                                    <h4><c:out value="${c.tenCombo}"/></h4>
                                    <span class="badge-pink" style="font-size:10px; padding:2px 6px;">Combo</span>
                                </div>
                                <p><c:out value="${not empty c.moTa ? c.moTa : 'Combo bắp nước chuẩn rạp CINEMAX'}"/></p>
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
    </div>

    <!-- 2. KHU VỰC SẢN PHẨM BÁN LẺ (BẮP / NƯỚC / ĐỒ ĂN VẶT) -->
    <div id="sectionProducts" style="margin-bottom: 24px;">
        <div style="display:flex; align-items:center; gap:8px; margin-bottom:12px;">
            <span style="font-size:16px;">🥤</span>
            <h4 style="margin:0; font-size:14px; font-weight:800; color:#0f172a; text-transform:uppercase; letter-spacing:0.5px;">Sản Phẩm Bán Lẻ (Bắp, Nước & Đồ Ăn)</h4>
            <span style="font-size:11px; background:#e0f2fe; color:#0369a1; padding:2px 8px; border-radius:10px; font-weight:700;">Gọi thêm món lẻ</span>
        </div>

        <c:choose>
            <c:when test="${empty listSanPham}">
                <div style="text-align:center; padding:24px; color:#94a3b8; background:#ffffff; border-radius:10px; border:1px dashed #e2e8f0;">
                    <p style="margin:0;">Chưa có sản phẩm lẻ nào trong hệ thống.</p>
                </div>
            </c:when>

            <c:otherwise>
                <div class="combo-grid">
                    <c:forEach items="${listSanPham}" var="sp">
                        <div class="combo-card is-sp-item" style="border-left: 3px solid #0284c7;"
                             data-search="<c:out value='${sp.tenSP} ${sp.loaiSP} ${sp.donViTinh} lẻ san pham'/>">
                            <div class="combo-info">
                                <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                                    <h4><c:out value="${sp.tenSP}"/></h4>
                                    <span style="font-size:10px; padding:2px 6px; background:#e0f2fe; color:#0369a1; font-weight:700; border-radius:4px;">
                                        <c:out value="${not empty sp.donViTinh ? sp.donViTinh : 'Món'}"/>
                                    </span>
                                </div>
                                <p style="color:#0369a1; font-weight:600; font-size:11px;">
                                    Phân loại: <c:out value="${not empty sp.loaiSP ? sp.loaiSP : 'Đồ uống / Bắp'}"/>
                                    <c:if test="${sp.soLuongTon > 0}">
                                        • Còn: ${sp.soLuongTon}
                                    </c:if>
                                </p>
                            </div>

                            <div class="combo-footer">
                                <div class="combo-price" style="color:#0284c7;">
                                    <fmt:formatNumber value="${sp.giaBan}" pattern="#,##0"/> đ
                                </div>

                                <!-- Nút tăng / giảm số lượng sản phẩm lẻ (+ / -) -->
                                <div class="counter-control">
                                    <button type="button" class="counter-btn"
                                            onclick="changeSanPhamQty('${sp.maSP}', '<c:out value="${sp.tenSP}"/>', ${sp.giaBan}, -1)">-</button>
                                    <span class="counter-val" id="item-qty-sp_${sp.maSP}">0</span>
                                    <button type="button" class="counter-btn"
                                            onclick="changeSanPhamQty('${sp.maSP}', '<c:out value="${sp.tenSP}"/>', ${sp.giaBan}, 1)">+</button>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Nút điều hướng chuyển tiếp -->
    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:24px; padding-top:16px; border-top:1px solid #e2e8f0; flex-wrap:wrap; gap:12px;">
        <a href="${pageContext.request.contextPath}/ban-ve?ngayChieu=${selectedNgay}&maSuat=${selectedSuat.maSuat}&step=2"
           class="btn btn-outline btn-sm" style="text-decoration:none;">
            ← Quay lại chọn ghế ngồi
        </a>
        <a href="${pageContext.request.contextPath}/thanh-toan?ngayChieu=${selectedNgay}&maSuat=${selectedSuat.maSuat}"
           class="btn btn-pink" style="text-decoration:none; font-weight:700;">
            ✓ Xác nhận đơn & Tiếp tục sang thanh toán →
        </a>
    </div>
</div>
