<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Soát Vé (Check-in) - Rạp Chiếu Phim CINEMAX</title>
    <!-- CSS hệ thống chung -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=16">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Thư viện quét mã vạch và QR code chuyên nghiệp qua Camera (html5-qrcode) -->
    <script src="https://unpkg.com/html5-qrcode" type="text/javascript"></script>

    <style>
        /* BỐ CỤC THỐNG KÊ TIẾN ĐỘ SOÁT VÉ */
        .stats-grid-checkin {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 20px;
        }
        .stat-card-mini {
            background: #ffffff;
            border-radius: var(--radius-md);
            padding: 16px 18px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border: 1px solid var(--border-subtle);
            box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        }
        .stat-card-mini .stat-title {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-secondary);
            margin-bottom: 4px;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }
        .stat-card-mini .stat-val {
            font-size: 22px;
            font-weight: 800;
            color: var(--text-primary);
        }
        .stat-icon-wrap {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }
        .icon-blue { background: #e0f2fe; color: #0284c7; }
        .icon-green { background: #dcfce7; color: #16a34a; }
        .icon-amber { background: #fef3c7; color: #d97706; }
        .icon-pink { background: #ffe4e6; color: #e11d48; }

        .progress-bar-wrap {
            width: 100%;
            height: 6px;
            background: #e2e8f0;
            border-radius: 99px;
            margin-top: 8px;
            overflow: hidden;
        }
        .progress-bar-fill {
            height: 100%;
            background: #16a34a;
            border-radius: 99px;
            transition: width 0.4s ease;
        }

        /* BỐ CỤC 2 CỘT QUÉT & KẾT QUẢ */
        .checkin-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 24px;
        }
        @media (max-width: 1100px) {
            .checkin-layout {
                grid-template-columns: 1fr;
                gap: 16px;
            }
            .stats-grid-checkin {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        @media (max-width: 600px) {
            .stats-grid-checkin {
                grid-template-columns: 1fr;
            }
        }

        .scan-card {
            background: #ffffff;
            border-radius: var(--radius-md);
            padding: 22px;
            border: 1px solid var(--border-subtle);
            box-shadow: 0 1px 4px rgba(0,0,0,0.04);
        }
        .card-title {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-primary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .scan-input-group {
            display: flex;
            gap: 8px;
            margin-bottom: 12px;
        }
        .scan-input {
            flex: 1;
            height: 48px;
            padding: 0 16px;
            font-size: 14px;
            font-weight: 600;
            border: 2px solid #cbd5e1;
            border-radius: 10px;
            outline: none;
            background: #f8fafc;
            color: #0f172a;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            transition: all 0.2s;
        }
        .scan-input:focus {
            border-color: #e11d48;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(225, 29, 72, 0.12);
        }
        .scan-btn {
            height: 48px;
            padding: 0 20px;
            font-size: 13.5px;
            font-weight: 700;
            background: #e11d48;
            color: #ffffff;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
            white-space: nowrap;
            box-shadow: 0 2px 6px rgba(225, 29, 72, 0.25);
        }
        .scan-btn:hover {
            background: #be123c;
            transform: translateY(-1px);
        }

        /* KHUNG HIỂN THỊ KẾT QUẢ SOÁT VÉ */
        .result-box {
            border-radius: 14px;
            padding: 24px;
            text-align: center;
            border: 2px dashed #cbd5e1;
            background: #f8fafc;
            min-height: 280px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            transition: all 0.3s ease;
        }
        .result-box.state-ready {
            border-color: #cbd5e1;
            background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
            color: #475569;
        }
        .result-box.state-success {
            border-color: #16a34a;
            border-style: solid;
            background: #f0fdf4;
            color: #14532d;
            box-shadow: 0 4px 14px rgba(22, 163, 74, 0.12);
        }
        .result-box.state-danger {
            border-color: #dc2626;
            border-style: solid;
            background: #fef2f2;
            color: #991b1b;
            box-shadow: 0 4px 14px rgba(220, 38, 38, 0.12);
        }
        .result-box.state-amber {
            border-color: #d97706;
            border-style: solid;
            background: #fffbeb;
            color: #92400e;
            box-shadow: 0 4px 14px rgba(217, 119, 6, 0.12);
        }

        .badge-status-lg {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 20px;
            border-radius: 30px;
            font-size: 14px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }
        .badge-success-lg { background: #dcfce7; color: #15803d; border: 1px solid #86efac; }
        .badge-danger-lg { background: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; }
        .badge-warning-lg { background: #fef3c7; color: #b45309; border: 1px solid #fde68a; }

        .ticket-highlight-card {
            background: #ffffff;
            border-radius: 14px;
            padding: 16px 20px;
            width: 100%;
            text-align: left;
            margin-top: 14px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
            border: 1px solid #e2e8f0;
            box-sizing: border-box;
        }
        .highlight-title {
            font-size: 17px;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 6px;
        }
        .highlight-meta {
            font-size: 13px;
            color: #475569;
            margin-bottom: 6px;
        }
        .highlight-seat-badge {
            display: inline-block;
            font-size: 24px;
            font-weight: 900;
            color: #e11d48;
            background: #ffe4e6;
            padding: 4px 16px;
            border-radius: 10px;
            border: 1px solid #fecdd3;
            letter-spacing: 1px;
        }

        /* NÚT DUYỆT ĐẶC CÁCH */
        .btn-force-checkin {
            background: #d97706;
            color: #ffffff;
            border: none;
            padding: 10px 18px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-top: 12px;
            transition: all 0.2s;
            box-shadow: 0 2px 4px rgba(217, 119, 6, 0.25);
        }
        .btn-force-checkin:hover {
            background: #b45309;
        }

        /* BẢNG LỊCH SỬ */
        .log-table-panel {
            background: #ffffff;
            border-radius: var(--radius-md);
            padding: 18px 20px;
            border: 1px solid var(--border-subtle);
            box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        }
        .custom-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }
        .custom-table th {
            background: #f8fafc;
            padding: 12px 14px;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-secondary);
            text-transform: uppercase;
            border-bottom: 1px solid var(--border-subtle);
        }
        .custom-table td {
            padding: 12px 14px;
            border-bottom: 1px solid var(--border-subtle);
            font-size: 13px;
            vertical-align: middle;
        }
    </style>
</head>
<body>
<div class="app-shell">
    <!-- MENU ĐIỀU HƯỚNG BÊN TRÁI (TỰ ĐỘNG THEO VAI TRÒ QUẢN LÝ / NHÂN VIÊN) -->
    <c:choose>
        <c:when test="${sessionScope.userRole == 'NhanVien' || sessionScope.userRole == 'Nhân viên'}">
            <jsp:include page="/menunv.jsp" />
        </c:when>
        <c:otherwise>
            <jsp:include page="/menuadmin.jsp" />
        </c:otherwise>
    </c:choose>

    <!-- KHUNG CHỨA NỘI DUNG CHÍNH (CHUẨN .main-wrapper TRÁNH TRÀN MÀN HÌNH) -->
    <div class="main-wrapper">
        <!-- THANH TOPBAR -->
        <header class="topbar">
            <div style="display:flex; align-items:center; gap:12px;">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div>
                    <h2 style="font-size:18px; font-weight:800; color:var(--text-primary); margin:0;">
                        <i class="fa-solid fa-qrcode" style="color:#e11d48; margin-right:6px;"></i> SOÁT VÉ VÀO PHÒNG CHIẾU (CHECK-IN)
                    </h2>
                    <span style="font-size:12px; color:var(--text-secondary);">
                        Quét mã QR / Barcode hoặc nhập mã vé để xác thực khách vào rạp
                    </span>
                </div>
            </div>
            <div style="font-size:13px; font-weight:700; color:#0f172a; background:#f1f5f9; padding:6px 14px; border-radius:20px; display:flex; align-items:center; gap:8px;">
                <i class="fa-solid fa-clock" style="color:#e11d48;"></i>
                <span id="liveClock">--:--:--</span>
            </div>
        </header>

        <!-- VÙNG NỘI DUNG -->
        <main class="content-area" style="padding: 20px 24px;">

            <!-- 1. TIẾN ĐỘ SOÁT VÉ CA TRỰC HÔM NAY -->
            <div class="stats-grid-checkin">
                <div class="stat-card-mini">
                    <div>
                        <div class="stat-title">Vé bán hôm nay</div>
                        <div class="stat-val" id="statTongVe">${thongKeCheckIn != null ? thongKeCheckIn.tongVeHomNay : 0}</div>
                    </div>
                    <div class="stat-icon-wrap icon-blue">
                        <i class="fa-solid fa-ticket"></i>
                    </div>
                </div>

                <div class="stat-card-mini">
                    <div>
                        <div class="stat-title">Đã vào rạp (Check-in)</div>
                        <div class="stat-val" style="color:#16a34a;" id="statDaCheckIn">${thongKeCheckIn != null ? thongKeCheckIn.veDaCheckIn : 0}</div>
                    </div>
                    <div class="stat-icon-wrap icon-green">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                </div>

                <div class="stat-card-mini">
                    <div>
                        <div class="stat-title">Chờ vào rạp</div>
                        <div class="stat-val" style="color:#d97706;" id="statChuaCheckIn">${thongKeCheckIn != null ? thongKeCheckIn.veChuaCheckIn : 0}</div>
                    </div>
                    <div class="stat-icon-wrap icon-amber">
                        <i class="fa-solid fa-hourglass-half"></i>
                    </div>
                </div>

                <div class="stat-card-mini">
                    <div style="width:100%;">
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <div class="stat-title">Tiến độ ca trực</div>
                            <span style="font-size:13px; font-weight:800; color:#16a34a;" id="statTyLe">${thongKeCheckIn != null ? thongKeCheckIn.tyLeCheckIn : 0}%</span>
                        </div>
                        <div class="progress-bar-wrap">
                            <div class="progress-bar-fill" id="statProgressBar" style="width: ${thongKeCheckIn != null ? thongKeCheckIn.tyLeCheckIn : 0}%;"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 2. LAYOUT 2 CỘT: QUÉT MÃ & KẾT QUẢ XÁC THỰC -->
            <div class="checkin-layout">
                <!-- CỘT TRÁI: KHUNG QUÉT MÃ VẠCH & MÃ QR -->
                <div class="scan-card">
                    <div class="card-title">
                        <span><i class="fa-solid fa-barcode" style="color:#e11d48; margin-right:6px;"></i> Quét vé hoặc nhập mã</span>
                        <span style="font-size:12px; font-weight:600; color:#16a34a;">
                            <i class="fa-solid fa-circle" style="font-size:8px;"></i> Máy quét tự động sẵn sàng
                        </span>
                    </div>

                    <div class="scan-input-group">
                        <input type="text" id="txtTicketCode" class="scan-input" autofocus
                               placeholder="Quét mã QR/Barcode bằng súng quét hoặc gõ mã vé rồi bấm Enter..."
                               onkeydown="if(event.key === 'Enter') submitCheckIn();">
                        <button type="button" class="scan-btn" onclick="submitCheckIn()">
                            <i class="fa-solid fa-check"></i> Kiểm tra (Enter)
                        </button>
                    </div>

                    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:8px;">
                        <button type="button" class="btn btn-outline btn-sm" id="btnToggleCamera" onclick="toggleCameraScanner()">
                            <i class="fa-solid fa-camera" style="margin-right:6px;"></i> Bật Camera quét mã
                        </button>
                        <button type="button" class="btn btn-ghost btn-sm" onclick="clearInput()">
                            <i class="fa-solid fa-eraser" style="margin-right:4px;"></i> Xóa ô nhập
                        </button>
                    </div>

                    <!-- KHUNG CAMERA QUÉT MÃ ĐA NĂNG (QR & BARCODE) -->
                    <div id="qrScannerContainer" style="display:none; margin-top:16px; border-radius:12px; overflow:hidden; border:2px dashed #94a3b8; padding:10px; background:#0f172a;">
                        <div id="reader" style="width:100%;"></div>
                        <div style="text-align:center; margin-top:8px;">
                            <button type="button" class="btn btn-sm btn-ghost" style="color:#fff;" onclick="toggleCameraScanner()">
                                ✕ Đóng camera
                            </button>
                        </div>
                    </div>

                    <!-- HƯỚNG DẪN THAO TÁC NGHIỆP VỤ -->
                    <div style="margin-top:16px; padding:14px 16px; background:#eff6ff; border:1px solid #bfdbfe; border-radius:12px; font-size:12.5px; color:#1e40af; line-height:1.6;">
                        <strong style="color:#1e3a8a; display:flex; align-items:center; gap:6px; margin-bottom:6px; font-size:13px;">
                            <i class="fa-solid fa-lightbulb" style="color:#3b82f6;"></i> MẸO DÀNH CHO NHÂN VIÊN SOÁT VÉ:
                        </strong>
                        <div style="color:#334155; margin-bottom:4px;">
                            • <strong>Máy quét tia đỏ / Barcode:</strong> Đưa đầu quét vào mã vạch ở cuống vé hoặc màn hình điện thoại, máy sẽ tự động đọc và kiểm tra.
                        </div>
                        <div style="color:#334155; margin-bottom:4px;">
                            • <strong>Nhập tay linh hoạt:</strong> Có thể gõ trực tiếp <strong>Mã vé</strong> (VD: <code>15</code>, <code>VE15</code>) hoặc <strong>Mã hóa đơn</strong> (<code>HD12</code>).
                        </div>
                        <div style="color:#64748b; font-size:11.5px; margin-top:6px; border-top:1px dashed #cbd5e1; padding-top:6px;">
                            <i class="fa-solid fa-shield-check" style="color:#16a34a;"></i> Tự động kiểm tra suất chiếu, phòng chiếu và ngăn chặn quét trùng 2 lần.
                        </div>
                    </div>
                </div>

                <!-- CỘT PHẢI: KẾT QUẢ SOÁT VÉ TRỰC QUAN -->
                <div class="scan-card">
                    <div class="card-title">
                        <span><i class="fa-solid fa-shield-halved" style="color:#e11d48; margin-right:6px;"></i> Kết quả xác thực</span>
                        <span id="txtCheckInTime" style="font-size:12px; color:#64748b;">--:--:--</span>
                    </div>

                    <div class="result-box state-ready" id="resultBox">
                        <div id="resultIcon" style="font-size:52px; margin-bottom:12px; color:#64748b;">
                            <i class="fa-solid fa-barcode"></i>
                        </div>
                        <div class="badge-status-lg" id="resultBadge" style="display:none;"></div>
                        <div id="resultMessage" style="font-size:16px; font-weight:800; color:#1e293b; margin-bottom:6px;">
                            SẴN SÀNG SOÁT VÉ
                        </div>
                        <div id="resultSub" style="font-size:12.5px; color:#64748b; max-width:320px;">
                            Vui lòng đưa vé in hoặc mã QR trên điện thoại trước máy quét để kiểm tra.
                        </div>

                        <!-- THÔNG TIN VÉ CHI TIẾT (KHI QUÉT THÀNH CÔNG HOẶC CẢNH BÁO) -->
                        <div class="ticket-highlight-card" id="ticketCard" style="display:none;">
                            <div class="highlight-title" id="hlMovie">Tên phim chiếu rạp</div>
                            <div class="highlight-meta" style="display:flex; flex-wrap:wrap; gap:6px; margin:8px 0;">
                                <span style="background:#e0f2fe; color:#0369a1; padding:3px 10px; border-radius:6px; font-weight:700; font-size:12px;">
                                    <i class="fa-solid fa-clock" style="margin-right:4px;"></i> <span id="hlTime">--:--</span>
                                </span>
                                <span style="background:#f1f5f9; color:#475569; padding:3px 10px; border-radius:6px; font-weight:600; font-size:12px;">
                                    <i class="fa-solid fa-calendar-day" style="margin-right:4px;"></i> <span id="hlDate">--/--/----</span>
                                </span>
                                <span style="background:#fef3c7; color:#92400e; padding:3px 10px; border-radius:6px; font-weight:700; font-size:12px;">
                                    <i class="fa-solid fa-door-open" style="margin-right:4px;"></i> <span id="hlRoom">Phòng 1</span>
                                </span>
                            </div>
                            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:10px; border-top:1px dashed #e2e8f0; padding-top:10px;">
                                <div>
                                    <span style="font-size:11px; font-weight:700; color:#64748b; display:block; text-transform:uppercase;">VỊ TRÍ GHẾ NGỒI:</span>
                                    <div class="highlight-seat-badge" id="hlSeat">A0</div>
                                </div>
                                <div style="text-align:right;">
                                    <span style="font-size:11px; font-weight:700; color:#64748b; display:block; text-transform:uppercase;">MÃ VÉ:</span>
                                    <strong style="font-size:16px; color:#e11d48; font-family:monospace;" id="hlTicketId">#00</strong>
                                </div>
                            </div>
                        </div>

                        <!-- NÚT DUYỆT ĐẶC CÁCH KHI BỊ CẢNH BÁO GIỜ/NGÀY (FORCE CHECK-IN) -->
                        <div id="forceApproveWrap" style="display:none;">
                            <button type="button" class="btn-force-checkin" onclick="forceApproveCurrentTicket()">
                                <i class="fa-solid fa-user-shield"></i> Duyệt đặc cách cho vào phòng
                            </button>
                            <div style="font-size:11px; color:#92400e; margin-top:4px;">
                                (Áp dụng khi có xác nhận của Quản lý rạp)
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 3. BẢNG LỊCH SỬ SOÁT VÉ GẦN ĐÂY -->
            <div class="log-table-panel">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                    <h3 style="font-size:14px; font-weight:700; color:var(--text-primary); margin:0; text-transform:uppercase;">
                        <i class="fa-solid fa-list-check" style="color:#e11d48; margin-right:6px;"></i> Danh sách vé vừa check-in gần nhất
                    </h3>
                    <span style="font-size:12px; color:#64748b;">Hiển thị 15 vé gần nhất trong ca trực</span>
                </div>

                <!-- Bọc overflow-x để không bao giờ bị tràn layout ở màn hình nhỏ -->
                <div style="overflow-x: auto; width: 100%;">
                    <table class="custom-table" style="min-width: 680px;">
                        <thead>
                        <tr>
                            <th style="width:85px;">Mã Vé</th>
                            <th>Tên Phim</th>
                            <th>Phòng Chiếu</th>
                            <th>Suất Chiếu</th>
                            <th>Ghế Ngồi</th>
                            <th>Mã Tra Cứu</th>
                            <th>Trạng Thái</th>
                        </tr>
                        </thead>
                        <tbody id="logTableBody">
                        <c:choose>
                            <c:when test="${empty lichSuCheckIn}">
                                <tr id="emptyLogRow">
                                    <td colspan="7" style="text-align:center; padding:28px; color:#94a3b8;">
                                        <i class="fa-solid fa-inbox" style="font-size:22px; margin-bottom:6px; display:block;"></i>
                                        Chưa có lượt check-in nào trong ca trực hôm nay.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${lichSuCheckIn}" var="v">
                                    <tr>
                                        <td>
                                            <span style="font-weight:700; color:#e11d48; background:#ffe4e6; padding:2px 8px; border-radius:6px;">
                                                #VE${v.maVe}
                                            </span>
                                        </td>
                                        <td><strong><c:out value="${v.tenPhim}"/></strong></td>
                                        <td><c:out value="${v.tenPhong}"/></td>
                                        <td><strong>${v.gioChieu}</strong> • ${v.ngayChieu}</td>
                                        <td>
                                            <span style="display:inline-block; font-weight:800; color:#e11d48; background:#fff1f2; padding:2px 8px; border-radius:6px; border:1px solid #fecdd3;">
                                                ${v.tenGhe}
                                            </span>
                                        </td>
                                        <td style="font-family:monospace; font-size:11px; color:#64748b;">${v.maQR}</td>
                                        <td>
                                            <span style="background:#dcfce7; color:#15803d; border:1px solid #86efac; font-size:11px; padding:3px 8px; border-radius:12px; font-weight:700;">
                                                ● Đã check-in
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

        </main>
    </div>
</div>

<script>
    // Biến lưu mã vé hiện tại để hỗ trợ duyệt đặc cách nếu cần
    let lastCheckedCode = '';

    // Đồng hồ thời gian thực
    function updateClock() {
        const now = new Date();
        const timeStr = now.toLocaleTimeString('vi-VN');
        const el = document.getElementById('liveClock');
        if (el) el.textContent = timeStr;
    }
    setInterval(updateClock, 1000);
    updateClock();

    function clearInput() {
        const inp = document.getElementById('txtTicketCode');
        if (inp) {
            inp.value = '';
            inp.focus();
        }
    }

    // Cập nhật số liệu thống kê ca trực khi check-in thành công
    function updateLiveStats() {
        const elDa = document.getElementById('statDaCheckIn');
        const elChua = document.getElementById('statChuaCheckIn');
        const elTong = document.getElementById('statTongVe');
        const elTyLe = document.getElementById('statTyLe');
        const elBar = document.getElementById('statProgressBar');

        if (elDa && elChua && elTong) {
            let da = parseInt(elDa.textContent) || 0;
            let chua = parseInt(elChua.textContent) || 0;
            let tong = parseInt(elTong.textContent) || (da + chua);

            da += 1;
            if (chua > 0) chua -= 1;
            elDa.textContent = da;
            elChua.textContent = chua;

            let pct = tong > 0 ? Math.round((da * 100.0) / tong) : 100;
            if (pct > 100) pct = 100;
            if (elTyLe) elTyLe.textContent = pct + '%';
            if (elBar) elBar.style.width = pct + '%';
        }
    }

    // Gửi yêu cầu soát vé tới máy chủ
    function submitCheckIn(codeParam, isForce) {
        const input = document.getElementById('txtTicketCode');
        const code = codeParam ? codeParam.trim() : (input ? input.value.trim() : '');

        if (!code) {
            alert('Vui lòng nhập hoặc quét mã vé!');
            if (input) input.focus();
            return;
        }

        lastCheckedCode = code;

        const resultBox = document.getElementById('resultBox');
        const resultIcon = document.getElementById('resultIcon');
        const resultBadge = document.getElementById('resultBadge');
        const resultMessage = document.getElementById('resultMessage');
        const resultSub = document.getElementById('resultSub');
        const ticketCard = document.getElementById('ticketCard');
        const forceWrap = document.getElementById('forceApproveWrap');

        // Hiển thị trạng thái đang tra cứu
        resultBox.className = 'result-box state-ready';
        resultIcon.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';
        resultBadge.style.display = 'none';
        resultMessage.textContent = 'Đang tra cứu dữ liệu vé...';
        resultSub.textContent = 'Mã quét: ' + code;
        ticketCard.style.display = 'none';
        if (forceWrap) forceWrap.style.display = 'none';

        const postBody = 'code=' + encodeURIComponent(code) + (isForce ? '&forceCheckIn=true' : '');

        fetch('${pageContext.request.contextPath}/check-in', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: postBody
        })
        .then(res => res.json())
        .then(data => {
            document.getElementById('txtCheckInTime').textContent = data.thoiGianCheckIn || '';

            if (data.success && data.statusCode === 'SUCCESS') {
                // 1. THÀNH CÔNG: Vé hợp lệ, cho vào phòng chiếu
                resultBox.className = 'result-box state-success';
                resultIcon.innerHTML = '<i class="fa-solid fa-circle-check" style="color:#16a34a;"></i>';
                resultBadge.className = 'badge-status-lg badge-success-lg';
                resultBadge.innerHTML = '<i class="fa-solid fa-check"></i> ' + (isForce ? 'ĐẶC CÁCH HỢP LỆ' : 'CHECK-IN HỢP LỆ');
                resultBadge.style.display = 'inline-flex';
                resultMessage.textContent = isForce ? 'Đã duyệt đặc cách cho khách vào phòng chiếu!' : 'Xác thực thành công! Mời quý khách vào xem phim.';
                resultSub.textContent = data.message || '';

                if (data.ve) {
                    fillTicketCard(data.ve);
                    prependLogRow(data.ve);
                }

                updateLiveStats();
                playSuccessSound();

            } else if (data.statusCode === 'ALREADY_CHECKED_IN') {
                // 2. CẢNH BÁO GIAN LẬN: Vé đã quét trước đó
                resultBox.className = 'result-box state-danger';
                resultIcon.innerHTML = '<i class="fa-solid fa-triangle-exclamation" style="color:#dc2626;"></i>';
                resultBadge.className = 'badge-status-lg badge-danger-lg';
                resultBadge.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> VÉ ĐÃ ĐƯỢC CHECK-IN!';
                resultBadge.style.display = 'inline-flex';
                resultMessage.textContent = 'CẢNH BÁO: Vé này ĐÃ ĐƯỢC SOÁT VÉ trước đó!';
                resultSub.textContent = (data.message || '') + ' - Không được phép vào cửa lại!';

                if (data.ve) fillTicketCard(data.ve);
                playErrorSound();

            } else if (data.statusCode === 'NOT_PAID') {
                // 3. ĐƠN CHƯA THANH TOÁN
                resultBox.className = 'result-box state-amber';
                resultIcon.innerHTML = '<i class="fa-solid fa-hourglass-half" style="color:#d97706;"></i>';
                resultBadge.className = 'badge-status-lg badge-warning-lg';
                resultBadge.innerHTML = '<i class="fa-solid fa-clock"></i> ĐƠN CHƯA THANH TOÁN';
                resultBadge.style.display = 'inline-flex';
                resultMessage.textContent = 'Hóa đơn của vé này chưa hoàn tất thanh toán!';
                resultSub.textContent = 'Khách cần hoàn tất thanh toán tại quầy thu ngân trước khi vào rạp.';

                if (data.ve) fillTicketCard(data.ve);
                playErrorSound();

            } else if (data.canForce) {
                // 4. CẢNH BÁO GIỜ/NGÀY (ĐẾN QUÁ SỚM, QUÁ GIỜ HOẶC SAI NGÀY) -> HỖ TRỢ DUYỆT ĐẶC CÁCH
                resultBox.className = 'result-box state-amber';
                resultIcon.innerHTML = '<i class="fa-solid fa-clock-rotate-left" style="color:#d97706;"></i>';
                resultBadge.className = 'badge-status-lg badge-warning-lg';
                resultBadge.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> CẢNH BÁO SUẤT CHIẾU';
                resultBadge.style.display = 'inline-flex';
                resultMessage.textContent = data.message || 'Chưa đúng giờ chiếu!';
                resultSub.textContent = 'Vui lòng kiểm tra lại thời gian của suất chiếu hoặc duyệt đặc cách bên dưới.';

                if (data.ve) fillTicketCard(data.ve);
                if (forceWrap) forceWrap.style.display = 'block';

                playErrorSound();

            } else {
                // 5. VÉ KHÔNG HỢP LỆ HOẶC KHÔNG TÌM THẤY
                resultBox.className = 'result-box state-danger';
                resultIcon.innerHTML = '<i class="fa-solid fa-circle-xmark" style="color:#dc2626;"></i>';
                resultBadge.className = 'badge-status-lg badge-danger-lg';
                resultBadge.innerHTML = '<i class="fa-solid fa-xmark"></i> VÉ KHÔNG HỢP LỆ';
                resultBadge.style.display = 'inline-flex';
                resultMessage.textContent = data.message || 'Không tìm thấy thông tin vé!';
                resultSub.textContent = 'Vui lòng kiểm tra lại mã vé hoặc mã QR trên phiếu in.';
                ticketCard.style.display = 'none';

                playErrorSound();
            }

            // Xóa và tự động focus lại ô nhập để sẵn sàng quét vé tiếp theo
            if (input) {
                input.value = '';
                input.focus();
            }
        })
        .catch(err => {
            console.error(err);
            resultBox.className = 'result-box state-danger';
            resultIcon.innerHTML = '<i class="fa-solid fa-triangle-exclamation" style="color:#dc2626;"></i>';
            resultMessage.textContent = 'Lỗi kết nối tới máy chủ!';
            resultSub.textContent = err.message;
            if (input) input.focus();
        });
    }

    // Duyệt đặc cách cho mã vé hiện tại
    function forceApproveCurrentTicket() {
        if (!lastCheckedCode) return;
        if (confirm('Bạn có chắc chắn muốn DUYỆT ĐẶC CÁCH cho khách vào phòng chiếu không?')) {
            submitCheckIn(lastCheckedCode, true);
        }
    }

    function fillTicketCard(ve) {
        const ticketCard = document.getElementById('ticketCard');
        document.getElementById('hlMovie').textContent = ve.tenPhim || 'Phim chiếu rạp';
        document.getElementById('hlTime').textContent = ve.gioChieu || '--:--';
        document.getElementById('hlDate').textContent = ve.ngayChieu || '';
        document.getElementById('hlRoom').textContent = ve.tenPhong || 'Phòng chiếu';
        document.getElementById('hlSeat').textContent = ve.tenGhe || '--';
        document.getElementById('hlTicketId').textContent = '#VE' + ve.maVe;
        ticketCard.style.display = 'block';
    }

    // Thêm dòng mới vào đầu bảng log
    function prependLogRow(ve) {
        const tbody = document.getElementById('logTableBody');
        if (!tbody) return;

        const emptyRow = document.getElementById('emptyLogRow');
        if (emptyRow) emptyRow.remove();

        const tr = document.createElement('tr');
        tr.style.background = '#f0fdf4';
        tr.innerHTML = `
            <td>
                <span style="font-weight:700; color:#e11d48; background:#ffe4e6; padding:2px 8px; border-radius:6px;">
                    #VE\${ve.maVe}
                </span>
            </td>
            <td><strong>\${ve.tenPhim || ''}</strong></td>
            <td>\${ve.tenPhong || ''}</td>
            <td><strong>\${ve.gioChieu || ''}</strong> • \${ve.ngayChieu || ''}</td>
            <td>
                <span style="display:inline-block; font-weight:800; color:#e11d48; background:#fff1f2; padding:2px 8px; border-radius:6px; border:1px solid #fecdd3;">
                    \${ve.tenGhe || ''}
                </span>
            </td>
            <td style="font-family:monospace; font-size:11px; color:#64748b;">\${ve.maQR || ('VE' + ve.maVe)}</td>
            <td>
                <span style="background:#dcfce7; color:#15803d; border:1px solid #86efac; font-size:11px; padding:3px 8px; border-radius:12px; font-weight:700;">
                    ● Đã check-in
                </span>
            </td>
        `;
        tbody.insertBefore(tr, tbody.firstChild);

        setTimeout(function() {
            tr.style.transition = 'background 1s ease';
            tr.style.background = '#ffffff';
        }, 2000);
    }

    // Phát âm thanh bip bíp thành công bằng Web Audio API thuần
    function playSuccessSound() {
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(880, ctx.currentTime);
            gain.gain.setValueAtTime(0.12, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.2);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start();
            osc.stop(ctx.currentTime + 0.2);
        } catch (e) {}
    }

    function playErrorSound() {
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type = 'sawtooth';
            osc.frequency.setValueAtTime(220, ctx.currentTime);
            gain.gain.setValueAtTime(0.15, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.35);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start();
            osc.stop(ctx.currentTime + 0.35);
        } catch (e) {}
    }

    // Camera Barcode & QR Scanner với Html5Qrcode
    let html5QrCode = null;
    let isCameraActive = false;

    function toggleCameraScanner() {
        const container = document.getElementById('qrScannerContainer');
        const btn = document.getElementById('btnToggleCamera');

        if (!isCameraActive) {
            container.style.display = 'block';
            btn.innerHTML = '<i class="fa-solid fa-video-slash" style="margin-right:6px;"></i> Tắt Camera';

            if (!html5QrCode) {
                html5QrCode = new Html5Qrcode("reader");
            }

            // Hỗ trợ quét cả QR Code và Barcode 1D (Code 128, Code 39, EAN 13, ...)
            const config = {
                fps: 15,
                qrbox: { width: 300, height: 180 }
            };

            html5QrCode.start(
                { facingMode: "environment" },
                config,
                (decodedText, decodedResult) => {
                    // Quét thành công
                    submitCheckIn(decodedText);
                    if (html5QrCode) {
                        html5QrCode.pause();
                        setTimeout(() => {
                            if (html5QrCode && isCameraActive) html5QrCode.resume();
                        }, 2500);
                    }
                },
                (errorMessage) => {
                    // Đang quét...
                }
            ).catch(err => {
                alert('Không thể mở Camera: ' + err);
                container.style.display = 'none';
                btn.innerHTML = '<i class="fa-solid fa-camera" style="margin-right:6px;"></i> Bật Camera quét mã';
                isCameraActive = false;
            });

            isCameraActive = true;
        } else {
            if (html5QrCode) {
                html5QrCode.stop().then(() => {
                    container.style.display = 'none';
                    btn.innerHTML = '<i class="fa-solid fa-camera" style="margin-right:6px;"></i> Bật Camera quét mã';
                    isCameraActive = false;
                }).catch(err => {
                    container.style.display = 'none';
                    btn.innerHTML = '<i class="fa-solid fa-camera" style="margin-right:6px;"></i> Bật Camera quét mã';
                    isCameraActive = false;
                });
            } else {
                container.style.display = 'none';
                btn.innerHTML = '<i class="fa-solid fa-camera" style="margin-right:6px;"></i> Bật Camera quét mã';
                isCameraActive = false;
            }
        }
    }
</script>

<!-- Tự động làm sáng menu Soát vé (Check-in) -->
<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=16"></script>
<script>
    if (typeof initSidebarHighlight === 'function') {
        initSidebarHighlight();
    }
</script>
</body>
</html>
