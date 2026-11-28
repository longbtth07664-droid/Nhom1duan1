<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Khuyến Mãi & Voucher - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=12">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .km-layout {
            display: grid;
            grid-template-columns: 400px 1fr;
            gap: 20px;
            align-items: flex-start;
        }
        @media (max-width: 1180px) {
            .km-layout {
                grid-template-columns: 1fr;
            }
        }
        .km-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 20px;
            border: 1px solid var(--border-subtle);
            box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        }
        .km-card-title {
            font-size: 15px;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 16px;
            padding-bottom: 10px;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .form-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }
        .form-group {
            margin-bottom: 12px;
        }
        .form-group label {
            display: block;
            font-size: 11.5px;
            font-weight: 700;
            color: #475569;
            margin-bottom: 4px;
            text-transform: uppercase;
        }
        .form-control {
            width: 100%;
            height: 36px;
            padding: 0 10px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 13px;
            color: #0f172a;
            background: #fff;
            box-sizing: border-box;
        }
        .form-control:focus {
            outline: none;
            border-color: #e11d48;
        }
        .thu-group {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }
        .thu-chip {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 8px;
            background: #f8fafc;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
        }
        .km-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        .km-table th {
            text-align: left;
            padding: 10px 12px;
            background: #f8fafc;
            color: #475569;
            font-size: 11.5px;
            font-weight: 800;
            text-transform: uppercase;
            border-bottom: 2px solid #e2e8f0;
        }
        .km-table td {
            padding: 12px;
            border-bottom: 1px solid #f1f5f9;
            vertical-align: top;
        }
        .code-badge {
            display: inline-block;
            background: #fff1f2;
            color: #e11d48;
            border: 1px dashed #fda4af;
            padding: 3px 8px;
            border-radius: 6px;
            font-weight: 800;
            font-size: 12px;
            letter-spacing: 0.5px;
        }
        .cond-pill {
            display: inline-block;
            font-size: 11px;
            font-weight: 600;
            padding: 2px 7px;
            border-radius: 99px;
            background: #eff6ff;
            color: #1d4ed8;
            margin: 2px 2px 0 0;
        }
        .cond-pill.age {
            background: #fef3c7;
            color: #92400e;
        }
        .cond-pill.day {
            background: #f3e8ff;
            color: #6b21a8;
        }
        .status-active {
            background: #dcfce7;
            color: #166534;
            padding: 3px 8px;
            border-radius: 99px;
            font-size: 11px;
            font-weight: 700;
        }
        .status-inactive {
            background: #f1f5f9;
            color: #64748b;
            padding: 3px 8px;
            border-radius: 99px;
            font-size: 11px;
            font-weight: 700;
        }
        .flash-banner {
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 16px;
            font-size: 13px;
            font-weight: 700;
        }
        .flash-success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #86efac;
        }
        .flash-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
        }
    </style>
</head>
<body>
<div class="app-shell">
    <jsp:include page="/menuadmin.jsp" />

    <main class="main-content">
        <header class="topbar" style="margin-bottom:20px; display:flex; justify-content:space-between; align-items:center;">
            <div>
                <h2 style="font-size:20px; font-weight:800; color:var(--text-primary); margin:0;">
                    QUẢN LÝ MÃ GIẢM GIÁ & KHUYẾN MÃI
                </h2>
                <span style="font-size:13px; color:var(--text-secondary);">
                    Cấu hình voucher theo khung giờ chiếu, thứ trong tuần, độ tuổi khách hàng &amp; giá trị đơn
                </span>
            </div>
            <form method="get" action="${pageContext.request.contextPath}/quan-ly-khuyen-mai" style="display:flex; gap:8px;">
                <input type="text" name="keyword" value="${keyword}" class="form-control" style="width:240px;" placeholder="Tìm tên hoặc mã code...">
                <button type="submit" class="btn btn-pink">Tìm kiếm</button>
                <c:if test="${not empty keyword}">
                    <a href="${pageContext.request.contextPath}/quan-ly-khuyen-mai" class="btn btn-outline">Xóa lọc</a>
                </c:if>
            </form>
        </header>

        <c:if test="${not empty sessionScope.kmFlashMsg}">
            <div class="flash-banner ${sessionScope.kmFlashType == 'success' ? 'flash-success' : 'flash-error'}">
                <i class="fa-solid ${sessionScope.kmFlashType == 'success' ? 'fa-circle-check' : 'fa-circle-exclamation'}" style="margin-right:6px;"></i>
                ${sessionScope.kmFlashMsg}
            </div>
            <c:remove var="kmFlashMsg" scope="session" />
            <c:remove var="kmFlashType" scope="session" />
        </c:if>

        <div class="km-layout">
            <!-- FORM THÊM / SỬA KHUYẾN MÃI -->
            <div class="km-card" style="border-top: 4px solid #e11d48;">
                <div class="km-card-title">
                    <span>
                        <i class="fa-solid fa-ticket" style="color:#e11d48; margin-right:6px;"></i>
                        ${editingKM != null ? 'CẬP NHẬT MÃ KHUYẾN MÃI' : 'THÊM MÃ KHUYẾN MÃI MỚI'}
                    </span>
                    <c:if test="${editingKM != null}">
                        <a href="${pageContext.request.contextPath}/quan-ly-khuyen-mai" style="font-size:12px; color:#64748b;">+ Tạo mới</a>
                    </c:if>
                </div>

                <form method="post" action="${pageContext.request.contextPath}/quan-ly-khuyen-mai">
                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="maKM" value="${editingKM != null ? editingKM.maKM : ''}">

                    <div class="form-group">
                        <label>Tên chương trình *</label>
                        <input type="text" name="tenKM" class="form-control" required
                               value="${editingKM != null ? editingKM.tenKM : ''}"
                               placeholder="VD: Ưu đãi HSSV U22 / Suất chiếu sớm">
                    </div>

                    <div class="form-grid-2">
                        <div class="form-group">
                            <label>Mã Code *</label>
                            <input type="text" name="maCode" class="form-control" required style="text-transform:uppercase; font-weight:700;"
                                   value="${editingKM != null ? editingKM.maCode : ''}"
                                   placeholder="VD: U22_STUDENT">
                        </div>
                        <div class="form-group">
                            <label>Phần trăm giảm (%)</label>
                            <input type="number" name="phanTramGiam" class="form-control" min="0" max="100" step="1"
                                   value="${editingKM != null ? editingKM.phanTramGiam.intValue() : 15}">
                        </div>
                    </div>

                    <div class="form-grid-2">
                        <div class="form-group">
                            <label>Giảm tối đa (VNĐ)</label>
                            <input type="number" name="soTienGiamToiDa" class="form-control" min="0" step="1000"
                                   value="${editingKM != null ? editingKM.soTienGiamToiDa.longValue() : 50000}">
                        </div>
                        <div class="form-group">
                            <label>Đơn tối thiểu (VNĐ)</label>
                            <input type="number" name="donToiThieu" class="form-control" min="0" step="1000"
                                   value="${editingKM != null ? editingKM.donToiThieu.longValue() : 0}">
                        </div>
                    </div>

                    <div class="form-grid-2">
                        <div class="form-group">
                            <label>Khung giờ chiếu từ</label>
                            <input type="time" name="gioChieuTu" class="form-control"
                                   value="${editingKM != null && editingKM.gioChieuTu != null ? editingKM.gioChieuTu.toString().substring(0,5) : ''}">
                        </div>
                        <div class="form-group">
                            <label>Khung giờ chiếu đến</label>
                            <input type="time" name="gioChieuDen" class="form-control"
                                   value="${editingKM != null && editingKM.gioChieuDen != null ? editingKM.gioChieuDen.toString().substring(0,5) : ''}">
                        </div>
                    </div>

                    <div class="form-grid-2">
                        <div class="form-group">
                            <label>Độ tuổi tối thiểu</label>
                            <input type="number" name="tuoiToiThieu" class="form-control" min="0" max="120"
                                   value="${editingKM != null ? editingKM.tuoiToiThieu : ''}"
                                   placeholder="Bỏ trống = không giới hạn">
                        </div>
                        <div class="form-group">
                            <label>Độ tuổi tối đa</label>
                            <input type="number" name="tuoiToiDa" class="form-control" min="0" max="120"
                                   value="${editingKM != null ? editingKM.tuoiToiDa : ''}"
                                   placeholder="Bỏ trống = không giới hạn">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Thứ trong tuần áp dụng (Bỏ trống = Tất cả các ngày)</label>
                        <c:set var="thuStr" value="${editingKM != null ? editingKM.thuTrongTuan : 'ALL'}" />
                        <div class="thu-group">
                            <label class="thu-chip"><input type="checkbox" name="thuTrongTuan" value="2" ${fn:contains(thuStr, '2') ? 'checked' : ''}> T2</label>
                            <label class="thu-chip"><input type="checkbox" name="thuTrongTuan" value="3" ${fn:contains(thuStr, '3') ? 'checked' : ''}> T3</label>
                            <label class="thu-chip"><input type="checkbox" name="thuTrongTuan" value="4" ${fn:contains(thuStr, '4') ? 'checked' : ''}> T4</label>
                            <label class="thu-chip"><input type="checkbox" name="thuTrongTuan" value="5" ${fn:contains(thuStr, '5') ? 'checked' : ''}> T5</label>
                            <label class="thu-chip"><input type="checkbox" name="thuTrongTuan" value="6" ${fn:contains(thuStr, '6') ? 'checked' : ''}> T6</label>
                            <label class="thu-chip"><input type="checkbox" name="thuTrongTuan" value="7" ${fn:contains(thuStr, '7') ? 'checked' : ''}> T7</label>
                            <label class="thu-chip"><input type="checkbox" name="thuTrongTuan" value="8" ${fn:contains(thuStr, '8') ? 'checked' : ''}> CN</label>
                        </div>
                    </div>

                    <div class="form-grid-2">
                        <div class="form-group">
                            <label>Số vé tối thiểu</label>
                            <input type="number" name="soVeToiThieu" class="form-control" min="1"
                                   value="${editingKM != null ? editingKM.soVeToiThieu : 1}">
                        </div>
                        <div class="form-group">
                            <label>Trạng thái</label>
                            <select name="trangThai" class="form-control">
                                <option value="Đang áp dụng" ${editingKM == null || editingKM.trangThai == 'Đang áp dụng' ? 'selected' : ''}>Đang áp dụng</option>
                                <option value="Tạm ngưng" ${editingKM != null && editingKM.trangThai == 'Tạm ngưng' ? 'selected' : ''}>Tạm ngưng</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-grid-2">
                        <div class="form-group">
                            <label>Ngày bắt đầu</label>
                            <input type="date" name="ngayBatDau" class="form-control"
                                   value="${editingKM != null && editingKM.ngayBatDau != null ? editingKM.ngayBatDau.toLocalDate() : ''}">
                        </div>
                        <div class="form-group">
                            <label>Ngày kết thúc</label>
                            <input type="date" name="ngayKetThuc" class="form-control"
                                   value="${editingKM != null && editingKM.ngayKetThuc != null ? editingKM.ngayKetThuc.toLocalDate() : ''}">
                        </div>
                    </div>

                    <button type="submit" class="btn btn-pink" style="width:100%; height:40px; font-weight:800; margin-top:6px;">
                        <i class="fa-solid fa-floppy-disk" style="margin-right:6px;"></i>
                        ${editingKM != null ? 'LƯU THAY ĐỔI' : 'TẠO MÃ KHUYẾN MÃI'}
                    </button>
                </form>
            </div>

            <!-- DANH SÁCH KHUYẾN MÃI -->
            <div class="km-card">
                <div class="km-card-title">
                    <span>DANH SÁCH CHƯƠNG TRÌNH KHUYẾN MÃI (${fn:length(listKhuyenMai)})</span>
                </div>

                <div style="overflow-x:auto;">
                    <table class="km-table">
                        <thead>
                            <tr>
                                <th>Mã &amp; Tên chương trình</th>
                                <th>Mức giảm</th>
                                <th>Điều kiện áp dụng</th>
                                <th>Thời hạn</th>
                                <th>Trạng thái</th>
                                <th style="text-align:right;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${listKhuyenMai}" var="km">
                                <tr>
                                    <td>
                                        <span class="code-badge">${km.maCode}</span>
                                        <div style="font-weight:700; color:#0f172a; margin-top:4px;">${km.tenKM}</div>
                                    </td>
                                    <td>
                                        <strong style="color:#e11d48; font-size:14px;">-${km.phanTramGiam.intValue()}%</strong>
                                        <div style="font-size:11.5px; color:#64748b;">
                                            Tối đa: <fmt:formatNumber value="${km.soTienGiamToiDa}" pattern="#,##0"/> đ
                                        </div>
                                        <c:if test="${km.donToiThieu > 0}">
                                            <div style="font-size:11px; color:#64748b;">
                                                Đơn từ: <fmt:formatNumber value="${km.donToiThieu}" pattern="#,##0"/> đ
                                            </div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:if test="${km.gioChieuTu != null || km.gioChieuDen != null}">
                                            <span class="cond-pill">
                                                🕒 ${km.gioChieuTu != null ? km.gioChieuTu.toString().substring(0,5) : '00:00'} - ${km.gioChieuDen != null ? km.gioChieuDen.toString().substring(0,5) : '23:59'}
                                            </span>
                                        </c:if>
                                        <c:if test="${km.tuoiToiThieu != null || km.tuoiToiDa != null}">
                                            <span class="cond-pill age">
                                                👤 ${km.tuoiToiThieu != null ? km.tuoiToiThieu : '0'} - ${km.tuoiToiDa != null ? km.tuoiToiDa : '100+'} tuổi
                                            </span>
                                        </c:if>
                                        <c:if test="${not empty km.thuTrongTuan && km.thuTrongTuan != 'ALL'}">
                                            <span class="cond-pill day">📅 Thứ ${km.thuTrongTuan}</span>
                                        </c:if>
                                        <c:if test="${km.soVeToiThieu > 1}">
                                            <span class="cond-pill">🎟️ Từ ${km.soVeToiThieu} vé</span>
                                        </c:if>
                                        <c:if test="${km.gioChieuTu == null && km.gioChieuDen == null && km.tuoiToiThieu == null && km.tuoiToiDa == null && (empty km.thuTrongTuan || km.thuTrongTuan == 'ALL') && km.soVeToiThieu <= 1}">
                                            <span style="font-size:11.5px; color:#64748b;">Mọi suất chiếu</span>
                                        </c:if>
                                    </td>
                                    <td style="font-size:12px; color:#475569; white-space:nowrap;">
                                        <div>Từ: ${km.ngayBatDau != null ? km.ngayBatDau.toLocalDate() : '-'}</div>
                                        <div>Đến: ${km.ngayKetThuc != null ? km.ngayKetThuc.toLocalDate() : '-'}</div>
                                    </td>
                                    <td>
                                        <span class="${km.trangThai == 'Đang áp dụng' ? 'status-active' : 'status-inactive'}">
                                            ${km.trangThai}
                                        </span>
                                    </td>
                                    <td style="text-align:right; white-space:nowrap;">
                                        <a href="${pageContext.request.contextPath}/quan-ly-khuyen-mai?action=edit&id=${km.maKM}"
                                           class="btn btn-sm btn-outline" title="Sửa">
                                            <i class="fa-solid fa-pen"></i>
                                        </a>
                                        <form method="post" action="${pageContext.request.contextPath}/quan-ly-khuyen-mai" style="display:inline;">
                                            <input type="hidden" name="action" value="toggle">
                                            <input type="hidden" name="id" value="${km.maKM}">
                                            <button type="submit" class="btn btn-sm btn-outline" title="Đổi trạng thái">
                                                <i class="fa-solid fa-power-off"></i>
                                            </button>
                                        </form>
                                        <form method="post" action="${pageContext.request.contextPath}/quan-ly-khuyen-mai" style="display:inline;"
                                              onsubmit="return confirm('Xác nhận xóa/hủy mã khuyến mãi [${km.maCode}]?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${km.maKM}">
                                            <button type="submit" class="btn btn-sm btn-outline" style="color:#dc2626;" title="Xóa">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty listKhuyenMai}">
                                <tr>
                                    <td colspan="6" style="text-align:center; padding:30px; color:#94a3b8;">
                                        Chưa có chương trình khuyến mãi nào. Hãy tạo mã mới ở form bên trái!
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
