<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Hóa Đơn & Vé - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=12">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Thư viện tạo mã vạch chuẩn quốc tế Code 128 (JsBarcode) -->
    <script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.6/dist/JsBarcode.all.min.js"></script>
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .stat-card {
            background: #ffffff;
            border-radius: var(--radius-md);
            padding: 18px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border: 1px solid var(--border-subtle);
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }
        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }
        .icon-green { background: #dcfce7; color: #16a34a; }
        .icon-blue { background: #e0f2fe; color: #0284c7; }
        .icon-pink { background: #ffe4e6; color: #e11d48; }
        .icon-purple { background: #f3e8ff; color: #9333ea; }

        .stat-info .label {
            font-size: 13px;
            color: var(--text-secondary);
            margin-bottom: 4px;
        }
        .stat-info .value {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-primary);
        }

        .filter-panel {
            background: #ffffff;
            border-radius: var(--radius-md);
            padding: 16px 20px;
            margin-bottom: 20px;
            border: 1px solid var(--border-subtle);
        }
        .filter-row {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            align-items: flex-end;
        }
        .filter-item {
            display: flex;
            flex-direction: column;
            gap: 6px;
            flex: 1;
            min-width: 150px;
        }
        .filter-item label {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-secondary);
        }
        .filter-input {
            height: 38px;
            padding: 0 12px;
            border: 1px solid var(--border-strong);
            border-radius: var(--radius-sm);
            background: var(--bg-input);
            font-size: 13px;
            color: var(--text-primary);
            outline: none;
            transition: border-color var(--transition);
        }
        .filter-input:focus {
            border-color: var(--pink);
            background: #fff;
        }

        .table-panel {
            background: #ffffff;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-subtle);
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        }

        /* PHÂN TRANG HÓA ĐƠN */
        .pagination-container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 20px;
            background: #ffffff;
            border-top: 1px solid var(--border-subtle);
            flex-wrap: wrap;
            gap: 12px;
        }
        .pagination-info {
            font-size: 13px;
            color: var(--text-secondary);
        }
        .pagination-controls {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .page-chip {
            min-width: 34px;
            height: 34px;
            padding: 0 8px;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
            background: #ffffff;
            color: #475569;
            font-size: 13px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .page-chip:hover {
            border-color: var(--pink);
            color: var(--pink);
            background: #fff1f2;
        }
        .page-chip.active {
            background: var(--pink);
            border-color: var(--pink);
            color: #ffffff;
            font-weight: 700;
            pointer-events: none;
        }
        .page-chip.disabled {
            opacity: 0.4;
            cursor: not-allowed;
            pointer-events: none;
            background: #f8fafc;
        }
        .custom-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }
        .custom-table th {
            background: #f8fafc;
            padding: 12px 16px;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-secondary);
            text-transform: uppercase;
            border-bottom: 1px solid var(--border-subtle);
        }
        .custom-table td {
            padding: 14px 16px;
            border-bottom: 1px solid var(--border-subtle);
            font-size: 13px;
            vertical-align: middle;
        }
        .custom-table tr:hover {
            background: #fafaf9;
        }

        .badge-pt {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }
        .badge-cash { background: #dcfce7; color: #15803d; }
        .badge-qr { background: #e0f2fe; color: #0369a1; }
        .badge-card { background: #f3e8ff; color: #7e22ce; }

        /* MODAL HÓA ĐƠN K80 */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
            z-index: 1000;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .modal-overlay.active {
            display: flex;
        }
        .modal-receipt {
            background: #ffffff;
            width: 100%;
            max-width: 440px;
            max-height: 90vh;
            border-radius: 16px;
            overflow-y: auto;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            display: flex;
            flex-direction: column;
        }
        .receipt-body {
            padding: 24px 28px;
            font-family: 'Courier New', Courier, monospace;
            color: #1e293b;
        }
        .receipt-cinema-name {
            font-size: 18px;
            font-weight: 800;
            text-align: center;
            letter-spacing: 1px;
            color: #0f172a;
        }
        .receipt-sub {
            font-size: 11px;
            text-align: center;
            color: #64748b;
            margin-top: 2px;
        }
        .receipt-divider {
            border-top: 1px dashed #94a3b8;
            margin: 14px 0;
        }
        .receipt-row {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            margin-bottom: 5px;
        }
        .receipt-row.bold {
            font-weight: 700;
            font-size: 13px;
        }
        .receipt-row.grand-total {
            font-size: 16px;
            font-weight: 800;
            color: #e11d48;
            margin-top: 6px;
        }
        .receipt-barcode {
            text-align: center;
            margin-top: 16px;
            padding-top: 12px;
            border-top: 1px dashed #cbd5e1;
        }
        .barcode-stripes {
            font-family: 'Libre Barcode 128', cursive, monospace;
            font-size: 38px;
            letter-spacing: 2px;
            line-height: 1;
        }
        .modal-actions {
            background: #f8fafc;
            padding: 14px 24px;
            border-top: 1px solid var(--border-subtle);
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        @media print {
            body * {
                visibility: hidden;
            }
            #printableReceipt, #printableReceipt * {
                visibility: visible;
            }
            #printableReceipt {
                position: absolute;
                left: 0;
                top: 0;
                width: 80mm;
                padding: 5mm;
                margin: 0;
                box-shadow: none;
            }
            .modal-actions, .app-shell, .filter-panel, .stats-grid, .table-panel {
                display: none !important;
            }
        }
    </style>
</head>
<body>
<div class="app-shell">
    <!-- MENU BÊN TRÁI -->
    <c:choose>
        <c:when test="${sessionScope.userRole == 'NhanVien' || sessionScope.userRole == 'Nhân viên'}">
            <jsp:include page="/menunv.jsp" />
        </c:when>
        <c:otherwise>
            <jsp:include page="/menuadmin.jsp" />
        </c:otherwise>
    </c:choose>

    <!-- NỘI DUNG CHÍNH -->
    <main class="main-content">
        <!-- TOPBAR -->
        <header class="topbar" style="margin-bottom:20px; display:flex; justify-content:space-between; align-items:center;">
            <div>
                <h2 style="font-size:22px; font-weight:800; color:var(--text-primary); margin:0;">
                    QUẢN LÝ HÓA ĐƠN & GIAO DỊCH
                </h2>
                <span style="font-size:13px; color:var(--text-secondary);">
                    Tra cứu toàn bộ lịch sử thanh toán vé, combo và in lại phiếu K80 rạp chiếu
                </span>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/ban-ve" class="btn btn-pink">
                    <i class="fa-solid fa-plus" style="margin-right:6px;"></i> Bán vé đơn mới
                </a>
            </div>
        </header>

        <!-- CARDS THỐNG KÊ -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-info">
                    <div class="label">Doanh thu hôm nay</div>
                    <div class="value" style="color:#16a34a;">
                        <fmt:formatNumber value="${thongKe.doanhThuHomNay}" pattern="#,##0"/> đ
                    </div>
                </div>
                <div class="stat-icon icon-green"><i class="fa-solid fa-calendar-day"></i></div>
            </div>

            <div class="stat-card">
                <div class="stat-info">
                    <div class="label">Tổng doanh thu</div>
                    <div class="value" style="color:#e11d48;">
                        <fmt:formatNumber value="${thongKe.tongDoanhThu}" pattern="#,##0"/> đ
                    </div>
                </div>
                <div class="stat-icon icon-pink"><i class="fa-solid fa-sack-dollar"></i></div>
            </div>

            <div class="stat-card">
                <div class="stat-info">
                    <div class="label">Hóa đơn hôm nay</div>
                    <div class="value">${thongKe.hoaDonHomNay} đơn</div>
                </div>
                <div class="stat-icon icon-blue"><i class="fa-solid fa-receipt"></i></div>
            </div>

            <div class="stat-card">
                <div class="stat-info">
                    <div class="label">Tổng số hóa đơn</div>
                    <div class="value">${thongKe.tongHoaDon} đơn</div>
                </div>
                <div class="stat-icon icon-purple"><i class="fa-solid fa-database"></i></div>
            </div>
        </div>

        <!-- BỘ LỌC TÌM KIẾM -->
        <div class="filter-panel">
            <form action="${pageContext.request.contextPath}/hoa-don" method="get" class="filter-row" id="invoiceFilterForm" onsubmit="document.getElementById('pageNumberInput').value = 1;">
                <input type="hidden" name="page" id="pageNumberInput" value="${currentPage != null ? currentPage : 1}">
                <input type="hidden" name="pageSize" id="pageSizeInput" value="${pageSize != null ? pageSize : 10}">
                <div class="filter-item" style="flex:2;">
                    <label>Tìm kiếm từ khóa</label>
                    <input type="text" name="keyword" value="<c:out value='${keyword}'/>"
                           class="filter-input" placeholder="Nhập Mã HĐ, Tên thu ngân...">
                </div>

                <div class="filter-item">
                    <label>Từ ngày</label>
                    <input type="date" name="fromDate" value="${fromDate}" class="filter-input">
                </div>

                <div class="filter-item">
                    <label>Đến ngày</label>
                    <input type="date" name="toDate" value="${toDate}" class="filter-input">
                </div>

                <div class="filter-item">
                    <label>Phương thức</label>
                    <select name="phuongThuc" class="filter-input">
                        <option value="">-- Tất cả --</option>
                        <option value="Tiền mặt" ${phuongThuc == 'Tiền mặt' ? 'selected' : ''}>Tiền mặt</option>
                        <option value="Chuyển khoản (VietQR)" ${phuongThuc == 'Chuyển khoản (VietQR)' ? 'selected' : ''}>Chuyển khoản (VietQR)</option>
                        <option value="Thẻ ngân hàng" ${phuongThuc == 'Thẻ ngân hàng' ? 'selected' : ''}>Thẻ ngân hàng</option>
                    </select>
                </div>

                <div class="filter-item">
                    <label>Trạng thái</label>
                    <select name="trangThai" class="filter-input">
                        <option value="">-- Tất cả --</option>
                        <option value="Đã hoàn tất" ${trangThai == 'Đã hoàn tất' ? 'selected' : ''}>Đã hoàn tất</option>
                        <option value="Chờ thanh toán" ${trangThai == 'Chờ thanh toán' ? 'selected' : ''}>Chờ thanh toán</option>
                        <option value="Đã hủy" ${trangThai == 'Đã hủy' ? 'selected' : ''}>Đã hủy</option>
                    </select>
                </div>

                <div style="display:flex; gap:8px;">
                    <button type="submit" class="btn btn-pink" style="height:38px;">
                        <i class="fa-solid fa-filter" style="margin-right:6px;"></i> Lọc
                    </button>
                    <a href="${pageContext.request.contextPath}/hoa-don" class="btn btn-ghost" style="height:38px;">
                        ↺ Đặt lại
                    </a>
                </div>
            </form>
        </div>

        <!-- BẢNG DANH SÁCH HÓA ĐƠN -->
        <div class="table-panel">
            <div style="overflow-x: auto; width: 100%;">
                <table class="custom-table" style="min-width: 700px;">
                <thead>
                <tr>
                    <th style="width:100px;">Mã HĐ</th>
                    <th>Thời gian lập</th>
                    <th>Thu ngân</th>
                    <th>Phương thức</th>
                    <th>Tổng tiền</th>
                    <th>Trạng thái</th>
                    <th style="text-align:center; width:220px;">Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty danhSachHoaDon}">
                        <tr>
                            <td colspan="7" style="text-align:center; padding:40px; color:#94a3b8;">
                                <i class="fa-solid fa-inbox" style="font-size:32px; margin-bottom:10px; display:block;"></i>
                                Không tìm thấy hóa đơn nào phù hợp với điều kiện tìm kiếm.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${danhSachHoaDon}" var="hd">
                            <tr>
                                <td>
                                    <span style="font-weight:700; color:#e11d48; background:#ffe4e6; padding:3px 8px; border-radius:6px;">
                                        #HD${hd.maDatVe}
                                    </span>
                                </td>
                                <td>${hd.ngayDatFormatted}</td>
                                <td>
                                    <i class="fa-solid fa-user-tie" style="color:#64748b; margin-right:4px;"></i>
                                    <strong><c:out value="${hd.tenThuNgan}"/></strong>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${hd.phuongThuc.contains('Chuyển khoản') || hd.phuongThuc.contains('VNPay') || hd.phuongThuc.contains('QR')}">
                                            <span class="badge-pt badge-qr"><i class="fa-solid fa-qrcode"></i> ${hd.phuongThuc}</span>
                                        </c:when>
                                        <c:when test="${hd.phuongThuc.contains('Thẻ')}">
                                            <span class="badge-pt badge-card"><i class="fa-solid fa-credit-card"></i> ${hd.phuongThuc}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-pt badge-cash"><i class="fa-solid fa-money-bill-wave"></i> Tiền mặt</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <strong style="color:#0f172a; font-size:14px;">${hd.tongTienFormatted}</strong>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${hd.trangThai == 'Chờ thanh toán'}">
                                            <span style="background:#fef3c7; color:#b45309; border:1px solid #fde68a; font-size:11px; padding:3px 8px; border-radius:12px; font-weight:700;">
                                                ⏳ Chờ thanh toán
                                            </span>
                                        </c:when>
                                        <c:when test="${hd.trangThai == 'Đã hủy'}">
                                            <span style="background:#fee2e2; color:#b91c1c; border:1px solid #fecaca; font-size:11px; padding:3px 8px; border-radius:12px; font-weight:600;">
                                                ✖ Đã hủy
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="background:#dcfce7; color:#15803d; border:1px solid #bbf7d0; font-size:11px; padding:3px 8px; border-radius:12px; font-weight:600;">
                                                ● <c:out value="${not empty hd.trangThai ? hd.trangThai : 'Đã hoàn tất'}"/>
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="text-align:center;">
                                    <div style="display:inline-flex; gap:6px; align-items:center;">
                                        <c:if test="${hd.trangThai == 'Chờ thanh toán'}">
                                            <button type="button" class="btn btn-sm" style="background:#16a34a; color:#fff; border:none; padding:4px 8px; border-radius:6px; font-size:12px; font-weight:600;"
                                                    onclick="openPayModal(${hd.maDatVe}, '${hd.tongTienFormatted}')" title="Thu tiền khách hàng & In hóa đơn">
                                                <i class="fa-solid fa-money-bill-wave"></i> Thu tiền
                                            </button>
                                            <button type="button" class="btn btn-sm" style="background:#fee2e2; color:#dc2626; border:1px solid #fca5a5; padding:4px 8px; border-radius:6px; font-size:12px; font-weight:600;"
                                                    onclick="cancelInvoice(${hd.maDatVe})" title="Hủy hóa đơn này">
                                                <i class="fa-solid fa-xmark"></i> Hủy
                                            </button>
                                        </c:if>
                                        <c:if test="${hd.trangThai != 'Đã hủy' && hd.trangThai != 'Chờ thanh toán'}">
                                            <button type="button" class="btn btn-sm" style="background:#eff6ff; color:#1d4ed8; border:1px solid #bfdbfe; padding:4px 8px; border-radius:6px; font-size:12px; font-weight:600;"
                                                    onclick="openExchangeModal(${hd.maDatVe})" title="Đổi sang suất chiếu khác (bảo lưu vé)">
                                                <i class="fa-solid fa-repeat"></i> Đổi suất
                                            </button>
                                        </c:if>
                                        <button type="button" class="btn btn-outline btn-sm" style="padding:4px 8px; border-radius:6px; font-size:12px;"
                                                onclick="viewInvoiceDetail(${hd.maDatVe})" title="Xem chi tiết & In phiếu">
                                            <i class="fa-solid fa-receipt" style="margin-right:4px;"></i> Chi tiết
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
            </div>

            <!-- KHỐI PHÂN TRANG (PAGINATION) -->
            <c:if test="${totalPages > 0}">
                <div class="pagination-container">
                    <div class="pagination-info">
                        Hiển thị từ <strong>${fromIndex}</strong> đến <strong>${toIndex}</strong> trong tổng số <strong>${totalItems}</strong> hóa đơn
                    </div>

                    <div class="pagination-controls">
                        <div style="display:flex; align-items:center; gap:6px; margin-right:12px;">
                            <span style="font-size:12px; color:var(--text-secondary);">Hiển thị:</span>
                            <select onchange="changePageSize(this.value)" style="height:32px; border-radius:6px; border:1px solid #cbd5e1; font-size:12px; padding:0 6px;">
                                <option value="5" ${pageSize == 5 ? 'selected' : ''}>5 / trang</option>
                                <option value="10" ${pageSize == 10 ? 'selected' : ''}>10 / trang</option>
                                <option value="20" ${pageSize == 20 ? 'selected' : ''}>20 / trang</option>
                                <option value="50" ${pageSize == 50 ? 'selected' : ''}>50 / trang</option>
                            </select>
                        </div>

                        <!-- Nút trang trước -->
                        <c:choose>
                            <c:when test="${currentPage > 1}">
                                <a href="javascript:void(0)" onclick="changePage(${currentPage - 1})" class="page-chip" title="Trang trước">
                                    <i class="fa-solid fa-angle-left"></i>
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span class="page-chip disabled"><i class="fa-solid fa-angle-left"></i></span>
                            </c:otherwise>
                        </c:choose>

                        <!-- Danh sách các số trang -->
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <c:if test="${p == 1 || p == totalPages || (p >= currentPage - 2 && p <= currentPage + 2)}">
                                <a href="javascript:void(0)" onclick="changePage(${p})" class="page-chip ${p == currentPage ? 'active' : ''}">
                                    ${p}
                                </a>
                            </c:if>
                        </c:forEach>

                        <!-- Nút trang sau -->
                        <c:choose>
                            <c:when test="${currentPage < totalPages}">
                                <a href="javascript:void(0)" onclick="changePage(${currentPage + 1})" class="page-chip" title="Trang sau">
                                    <i class="fa-solid fa-angle-right"></i>
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span class="page-chip disabled"><i class="fa-solid fa-angle-right"></i></span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>
        </div>
    </main>
</div>

<!-- MODAL POPUP XEM CHI TIẾT & IN VÉ K80 -->
<div class="modal-overlay" id="receiptModal">
    <div class="modal-receipt">
        <div class="receipt-body" id="printableReceipt">
            <div class="receipt-cinema-name">CINEMAX CINEMA</div>
            <div class="receipt-sub">Tầng 5, TTTM Vincom Center • Hotline: 1900 6868</div>
            <div class="receipt-sub" style="margin-bottom:8px;">--- PHIẾU VÉ & HÓA ĐƠN K80 ---</div>

            <div class="receipt-divider"></div>

            <div class="receipt-row">
                <span>Số HĐ:</span>
                <strong id="rcCode">HD00</strong>
            </div>
            <div class="receipt-row">
                <span>Ngày in:</span>
                <span id="rcDate">--/--/---- --:--</span>
            </div>
            <div class="receipt-row">
                <span>Thu ngân:</span>
                <span id="rcCashier">Thu ngân</span>
            </div>
            <div class="receipt-row">
                <span>Hình thức:</span>
                <span id="rcPaymentMethod">Tiền mặt</span>
            </div>

            <div class="receipt-divider"></div>

            <!-- PHẦN VÉ XEM PHIM -->
            <div style="font-weight:700; margin-bottom:6px; font-size:12px; text-transform:uppercase;">
                🎬 VÉ XEM PHIM
            </div>
            <div id="rcTicketsContainer">
                <!-- Sẽ được fill bằng JavaScript -->
            </div>

            <!-- PHẦN COMBO BẮP NƯỚC -->
            <div id="rcComboWrapper" style="margin-top:10px;">
                <div style="font-weight:700; margin-bottom:6px; font-size:12px; text-transform:uppercase;">
                    🍿 COMBO BẮP NƯỚC (F&B)
                </div>
                <div id="rcCombosContainer">
                    <!-- Sẽ được fill bằng JavaScript -->
                </div>
            </div>

            <div class="receipt-divider"></div>

            <div class="receipt-row grand-total">
                <span>TỔNG CỘNG:</span>
                <span id="rcTotalAmount">0 đ</span>
            </div>
            <div style="font-size:10px; color:#64748b; font-style:italic; text-align:right;">(Giá đã bao gồm 8% thuế GTGT)</div>

            <div class="receipt-barcode">
                <div style="text-align:center; margin:6px 0;">
                    <!-- Mã vạch Code 128 vẽ bằng SVG vector, máy quét và camera quét phát ăn ngay -->
                    <svg id="rcBarcodeSvg" style="max-width:100%; height:46px; margin:2px auto; display:block;"></svg>
                </div>
                <div style="font-size:11px; margin-top:2px; font-weight:700; color:#334155; font-family:monospace;" id="rcBarcodeText">CINEMAX-HD00</div>
                <div style="font-size:11px; color:#64748b; margin-top:8px;">
                    Vui lòng xuất trình mã QR/Barcode tại cổng soát vé trước giờ chiếu 10 phút.
                </div>
                <div style="font-size:12px; font-weight:700; margin-top:6px;">
                    Cảm ơn quý khách & Hẹn gặp lại!
                </div>
            </div>
        </div>

        <div class="modal-actions">
            <button type="button" class="btn btn-ghost" onclick="closeReceiptModal()">
                ✕ Đóng
            </button>
            <button type="button" class="btn btn-pink" onclick="window.print()">
                <i class="fa-solid fa-print" style="margin-right:6px;"></i> In hóa đơn (K80)
            </button>
        </div>
    </div>
</div>

<!-- MODAL THU TIỀN CHO HÓA ĐƠN CHỜ THANH TOÁN -->
<div class="modal-overlay" id="payModal">
    <div style="background:#ffffff; border-radius:16px; width:100%; max-width:440px; padding:24px; box-shadow:0 20px 25px -5px rgba(0,0,0,0.15);">
        <h3 style="font-size:18px; font-weight:800; color:#0f172a; margin-top:0; margin-bottom:12px; display:flex; align-items:center; gap:8px;">
            <i class="fa-solid fa-money-bill-wave" style="color:#16a34a;"></i> Thu tiền hóa đơn <span id="payModalTitleCode" style="color:#e11d48;"></span>
        </h3>
        <p style="font-size:13px; color:#64748b; margin-bottom:16px;">
            Vui lòng chọn hình thức khách thanh toán và xác nhận đã nhận đủ tiền:
        </p>

        <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px; padding:12px 16px; margin-bottom:16px; display:flex; justify-content:space-between; align-items:center;">
            <span style="font-size:13px; font-weight:600; color:#475569;">Tổng tiền cần thu:</span>
            <span id="payModalAmount" style="font-size:18px; font-weight:800; color:#e11d48;">0 đ</span>
        </div>

        <div style="margin-bottom:20px;">
            <label style="font-size:12px; font-weight:700; color:#334155; display:block; margin-bottom:8px;">PHƯƠNG THỨC THANH TOÁN:</label>
            <div style="display:flex; flex-direction:column; gap:8px;">
                <label style="display:flex; align-items:center; gap:10px; padding:10px 14px; border:1px solid #e2e8f0; border-radius:8px; cursor:pointer; font-size:13px; font-weight:600;">
                    <input type="radio" name="payModalMethod" value="Tiền mặt" checked style="accent-color:#e11d48;">
                    <span><i class="fa-solid fa-money-bill-wave" style="color:#16a34a; margin-right:6px;"></i> Tiền mặt</span>
                </label>
                <label style="display:flex; align-items:center; gap:10px; padding:10px 14px; border:1px solid #e2e8f0; border-radius:8px; cursor:pointer; font-size:13px; font-weight:600;">
                    <input type="radio" name="payModalMethod" value="Chuyển khoản (VietQR)" style="accent-color:#e11d48;">
                    <span><i class="fa-solid fa-qrcode" style="color:#0284c7; margin-right:6px;"></i> Chuyển khoản (VietQR)</span>
                </label>
                <label style="display:flex; align-items:center; gap:10px; padding:10px 14px; border:1px solid #e2e8f0; border-radius:8px; cursor:pointer; font-size:13px; font-weight:600;">
                    <input type="radio" name="payModalMethod" value="Thẻ ngân hàng" style="accent-color:#e11d48;">
                    <span><i class="fa-solid fa-credit-card" style="color:#9333ea; margin-right:6px;"></i> Thẻ ngân hàng (POS)</span>
                </label>
            </div>
        </div>

        <div style="display:flex; gap:10px; justify-content:flex-end;">
            <button type="button" class="btn btn-ghost" onclick="closePayModal()">Đóng</button>
            <button type="button" class="btn btn-pink" id="btnConfirmPay" onclick="submitPayNow()">
                <i class="fa-solid fa-check" style="margin-right:6px;"></i> Xác nhận đã thu tiền
            </button>
        </div>
    </div>
</div>

<script>
    function viewInvoiceDetail(id) {
        fetch('${pageContext.request.contextPath}/hoa-don?action=detail&id=' + id)
            .then(res => res.json())
            .then(data => {
                if (!data.success) {
                    alert(data.message || 'Không thể tải chi tiết hóa đơn!');
                    return;
                }

                document.getElementById('rcCode').textContent = '#' + data.maHienThi;
                document.getElementById('rcDate').textContent = data.ngayDat;
                document.getElementById('rcCashier').textContent = data.tenThuNgan;
                document.getElementById('rcPaymentMethod').textContent = data.phuongThuc;
                document.getElementById('rcTotalAmount').textContent = data.tongTienFormatted;
                const barcodeValue = 'HD' + data.maDatVe;
                document.getElementById('rcBarcodeText').textContent = 'CINEMAX-' + barcodeValue;

                // Vẽ mã vạch chuẩn Code 128 bằng JsBarcode
                if (window.JsBarcode) {
                    try {
                        JsBarcode("#rcBarcodeSvg", barcodeValue, {
                            format: "CODE128",
                            width: 1.8,
                            height: 42,
                            displayValue: false,
                            margin: 2
                        });
                    } catch (e) {
                        console.error("Lỗi vẽ mã vạch JsBarcode:", e);
                    }
                }

                // Render vé
                const ticketsContainer = document.getElementById('rcTicketsContainer');
                ticketsContainer.innerHTML = '';
                if (data.veList && data.veList.length > 0) {
                    data.veList.forEach(v => {
                        const div = document.createElement('div');
                        div.style.marginBottom = '8px';
                        div.style.paddingBottom = '6px';
                        div.style.borderBottom = '1px dotted #e2e8f0';
                        div.innerHTML = `
                            <div style="font-weight:700;">\${v.tenPhim || 'Phim chiếu rạp'}</div>
                            <div style="font-size:11px; color:#475569;">
                                Suất: <strong>\${v.gioChieu || ''}</strong> • \${v.ngayChieu || ''} | Phòng: \${v.tenPhong || ''}
                            </div>
                            <div class="receipt-row" style="margin-top:2px;">
                                <span>Ghế: <strong style="font-size:13px; color:#e11d48;">\${v.tenGhe}</strong></span>
                                <span>\${v.giaVeFormatted}</span>
                            </div>
                        `;
                        ticketsContainer.appendChild(div);
                    });
                } else {
                    ticketsContainer.innerHTML = '<div style="font-style:italic; font-size:11px; color:#94a3b8;">Không có thông tin vé</div>';
                }

                // Render combo
                const comboWrapper = document.getElementById('rcComboWrapper');
                const combosContainer = document.getElementById('rcCombosContainer');
                combosContainer.innerHTML = '';
                if (data.comboList && data.comboList.length > 0) {
                    comboWrapper.style.display = 'block';
                    data.comboList.forEach(c => {
                        const div = document.createElement('div');
                        div.className = 'receipt-row';
                        div.innerHTML = `
                            <span><strong>\${c.soLuong}x</strong> \${c.tenCombo}</span>
                            <span>\${c.thanhTienFormatted}</span>
                        `;
                        combosContainer.appendChild(div);
                    });
                } else {
                    comboWrapper.style.display = 'none';
                }

                document.getElementById('receiptModal').classList.add('active');
            })
            .catch(err => {
                console.error(err);
                alert('Có lỗi khi kết nối tới máy chủ!');
            });
    }

    function closeReceiptModal() {
        document.getElementById('receiptModal').classList.remove('active');
        // Nếu vừa in xong đơn vừa thu tiền thì reload để cập nhật bảng
        if (window.needsReloadAfterPrint) {
            window.location.reload();
        }
    }

    let currentPayingId = null;

    function openPayModal(maDatVe, tongTienFormatted) {
        currentPayingId = maDatVe;
        document.getElementById('payModalTitleCode').textContent = '#HD' + maDatVe;
        document.getElementById('payModalAmount').textContent = tongTienFormatted;
        document.getElementById('payModal').classList.add('active');
    }

    function closePayModal() {
        document.getElementById('payModal').classList.remove('active');
        currentPayingId = null;
    }

    function submitPayNow() {
        if (!currentPayingId) return;

        const radios = document.getElementsByName('payModalMethod');
        let selectedMethod = 'Tiền mặt';
        for (let r of radios) {
            if (r.checked) {
                selectedMethod = r.value;
                break;
            }
        }

        const btn = document.getElementById('btnConfirmPay');
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý...';

        fetch('${pageContext.request.contextPath}/hoa-don?action=payNow&id=' + currentPayingId + '&phuongThuc=' + encodeURIComponent(selectedMethod))
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    window.needsReloadAfterPrint = true;
                    closePayModal();
                    alert(data.message || 'Đã thu tiền và hoàn tất hóa đơn thành công!');
                    // Mở modal in vé ngay lập tức
                    viewInvoiceDetail(data.maDatVe);
                } else {
                    alert(data.message || 'Không thể cập nhật thu tiền!');
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fa-solid fa-check" style="margin-right:6px;"></i> Xác nhận đã thu tiền';
                }
            })
            .catch(err => {
                console.error(err);
                alert('Lỗi kết nối tới máy chủ!');
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-solid fa-check" style="margin-right:6px;"></i> Xác nhận đã thu tiền';
            });
    }

    function cancelInvoice(maDatVe) {
        if (!confirm('Bạn có chắc chắn muốn HỦY hóa đơn #HD' + maDatVe + ' không?\nCác ghế đã giữ sẽ được giải phóng lại cho phòng chiếu.')) {
            return;
        }

        fetch('${pageContext.request.contextPath}/hoa-don?action=cancel&id=' + maDatVe)
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    alert(data.message || 'Đã hủy hóa đơn thành công!');
                    window.location.reload();
                } else {
                    alert(data.message || 'Không thể hủy hóa đơn!');
                }
            })
            .catch(err => {
                console.error(err);
                alert('Lỗi kết nối tới máy chủ khi hủy hóa đơn!');
            });
    }

    // Đóng khi click ngoài modal
    document.getElementById('receiptModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeReceiptModal();
        }
    });

    function toggleSubmenu(button) {
        const parent = button.parentElement;
        parent.classList.toggle('open');
    }

    // Điều khiển phân trang
    function changePage(pageNum) {
        if (!pageNum || pageNum < 1) pageNum = 1;
        document.getElementById('pageNumberInput').value = pageNum;
        document.getElementById('invoiceFilterForm').submit();
    }

    function changePageSize(size) {
        document.getElementById('pageSizeInput').value = size;
        document.getElementById('pageNumberInput').value = 1;
        document.getElementById('invoiceFilterForm').submit();
    }

    // ==================== ĐỔI SUẤT CHIẾU (PHƯƠNG ÁN B) ====================
    let EXCHANGE_STATE = { maDatVe: null, requiredSeats: 0, selectedSeatIds: [] };

    function openExchangeModal(maDatVe) {
        EXCHANGE_STATE = { maDatVe: maDatVe, requiredSeats: 0, selectedSeatIds: [] };
        document.getElementById('exHdTitle').textContent = '#HD' + maDatVe;
        document.getElementById('exMovieTitle').textContent = 'Đang tải...';
        document.getElementById('exTicketCount').textContent = '0';
        document.getElementById('exShowtimeSelect').innerHTML = '<option value="">-- Đang tải suất chiếu --</option>';
        document.getElementById('exSeatContainer').innerHTML = '<div style="color:#64748b; font-size:12.5px;">Vui lòng chọn suất chiếu mới ở trên.</div>';
        document.getElementById('exchangeModal').classList.add('open');

        fetch('${pageContext.request.contextPath}/hoa-don?action=exchangeInfo&id=' + maDatVe)
            .then(r => r.json())
            .then(data => {
                if (!data.success || data.ticketCount <= 0) {
                    alert('Hóa đơn này không có vé hợp lệ để đổi suất!');
                    closeExchangeModal();
                    return;
                }
                EXCHANGE_STATE.requiredSeats = data.ticketCount;
                document.getElementById('exMovieTitle').textContent = data.tenPhim || 'Phim';
                document.getElementById('exTicketCount').textContent = data.ticketCount;
                const sel = document.getElementById('exShowtimeSelect');
                if (!data.showtimes || data.showtimes.length === 0) {
                    sel.innerHTML = '<option value="">-- Không còn suất chiếu thay thế cùng phim --</option>';
                } else {
                    sel.innerHTML = '<option value="">-- Chọn suất chiếu thay thế --</option>';
                    data.showtimes.forEach(s => {
                        const opt = document.createElement('option');
                        opt.value = s.maSuat;
                        opt.textContent = s.ngayChieu + ' ' + s.gioBatDau + ' • ' + s.tenPhong + ' (' + s.dinhDang + ')';
                        sel.appendChild(opt);
                    });
                }
            })
            .catch(() => {
                alert('Lỗi tải thông tin đổi suất!');
                closeExchangeModal();
            });
    }

    function onExchangeShowtimeChange(maSuat) {
        EXCHANGE_STATE.selectedSeatIds = [];
        const container = document.getElementById('exSeatContainer');
        if (!maSuat) {
            container.innerHTML = '<div style="color:#64748b; font-size:12.5px;">Vui lòng chọn suất chiếu mới ở trên.</div>';
            return;
        }
        container.innerHTML = '<div style="color:#64748b; font-size:12.5px;">Đang tải ghế trống...</div>';
        fetch('${pageContext.request.contextPath}/hoa-don?action=exchangeSeats&maSuat=' + encodeURIComponent(maSuat))
            .then(r => r.json())
            .then(data => {
                const seats = data.seats || [];
                if (seats.length < EXCHANGE_STATE.requiredSeats) {
                    container.innerHTML = '<div style="color:#dc2626; font-size:12.5px; font-weight:600;">Suất này chỉ còn ' + seats.length + ' ghế trống, không đủ ' + EXCHANGE_STATE.requiredSeats + ' ghế để đổi!</div>';
                    return;
                }
                let html = '<div style="display:flex; flex-wrap:wrap; gap:6px; max-height:180px; overflow-y:auto; padding:4px;">';
                seats.forEach(s => {
                    html += '<button type="button" class="ex-seat-btn" data-id="' + s.maGhe + '" onclick="toggleExchangeSeat(this, ' + s.maGhe + ')" ' +
                        'style="padding:5px 10px; border-radius:6px; border:1px solid #cbd5e1; background:#fff; font-size:12px; font-weight:700; cursor:pointer;">' +
                        s.tenGhe + '</button>';
                });
                html += '</div>';
                container.innerHTML = html;
            });
    }

    function toggleExchangeSeat(btn, maGhe) {
        const idx = EXCHANGE_STATE.selectedSeatIds.indexOf(maGhe);
        if (idx >= 0) {
            EXCHANGE_STATE.selectedSeatIds.splice(idx, 1);
            btn.style.background = '#fff';
            btn.style.color = '#0f172a';
            btn.style.borderColor = '#cbd5e1';
        } else {
            if (EXCHANGE_STATE.selectedSeatIds.length >= EXCHANGE_STATE.requiredSeats) {
                alert('Chỉ được chọn đúng ' + EXCHANGE_STATE.requiredSeats + ' ghế tương ứng với số vé đã mua!');
                return;
            }
            EXCHANGE_STATE.selectedSeatIds.push(maGhe);
            btn.style.background = '#e11d48';
            btn.style.color = '#fff';
            btn.style.borderColor = '#e11d48';
        }
    }

    function confirmExchangeShowtime() {
        const maSuat = document.getElementById('exShowtimeSelect').value;
        if (!maSuat) {
            alert('Vui lòng chọn suất chiếu mới!');
            return;
        }
        if (EXCHANGE_STATE.selectedSeatIds.length !== EXCHANGE_STATE.requiredSeats) {
            alert('Vui lòng chọn đủ ' + EXCHANGE_STATE.requiredSeats + ' ghế mới!');
            return;
        }
        const url = '${pageContext.request.contextPath}/hoa-don?action=confirmExchange'
            + '&id=' + EXCHANGE_STATE.maDatVe
            + '&maSuat=' + encodeURIComponent(maSuat)
            + '&seatIds=' + encodeURIComponent(EXCHANGE_STATE.selectedSeatIds.join(','));
        fetch(url)
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    alert(data.message);
                    window.location.reload();
                } else {
                    alert(data.message || 'Đổi suất thất bại!');
                }
            })
            .catch(() => alert('Lỗi kết nối khi đổi suất chiếu!'));
    }

    function closeExchangeModal() {
        document.getElementById('exchangeModal').classList.remove('open');
    }
</script>

<!-- MODAL ĐỔI SUẤT CHIẾU (PHƯƠNG ÁN B) -->
<div class="modal-overlay" id="exchangeModal">
    <div style="background:#fff; width:520px; max-width:95vw; border-radius:14px; overflow:hidden; box-shadow:0 20px 40px rgba(0,0,0,0.2);">
        <div style="padding:16px 20px; border-bottom:1px solid #e2e8f0; display:flex; justify-content:space-between; align-items:center;">
            <strong style="font-size:15px; color:#0f172a;">🔄 Đổi Suất Chiếu &amp; Bảo Lưu Vé (<span id="exHdTitle"></span>)</strong>
            <button type="button" onclick="closeExchangeModal()" style="border:none; background:none; font-size:20px; cursor:pointer; color:#64748b;">&times;</button>
        </div>
        <div style="padding:18px 20px;">
            <div style="background:#f8fafc; padding:10px 12px; border-radius:8px; margin-bottom:14px; font-size:13px;">
                <div>Phim: <strong id="exMovieTitle" style="color:#e11d48;"></strong></div>
                <div>Số lượng vé cần đổi: <strong id="exTicketCount">0</strong> vé (Giữ nguyên tiền &amp; điểm tích lũy)</div>
            </div>
            <div style="margin-bottom:14px;">
                <label style="display:block; font-size:12px; font-weight:700; color:#475569; margin-bottom:6px;">CHỌN SUẤT CHIẾU THAY THẾ *</label>
                <select id="exShowtimeSelect" onchange="onExchangeShowtimeChange(this.value)"
                        style="width:100%; height:38px; padding:0 10px; border:1px solid #cbd5e1; border-radius:8px; font-size:13px;"></select>
            </div>
            <div>
                <label style="display:block; font-size:12px; font-weight:700; color:#475569; margin-bottom:6px;">CHỌN GHẾ TRỐNG TẠI SUẤT MỚI *</label>
                <div id="exSeatContainer" style="border:1px solid #e2e8f0; border-radius:8px; padding:10px; background:#f8fafc;"></div>
            </div>
        </div>
        <div style="padding:12px 20px; background:#f8fafc; border-top:1px solid #e2e8f0; display:flex; justify-content:flex-end; gap:8px;">
            <button type="button" class="btn btn-outline" onclick="closeExchangeModal()">Hủy</button>
            <button type="button" class="btn btn-pink" onclick="confirmExchangeShowtime()">Xác nhận đổi suất</button>
        </div>
    </div>
</div>
</body>
</html>
