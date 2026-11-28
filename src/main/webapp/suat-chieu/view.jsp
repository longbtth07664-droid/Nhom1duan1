<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Lịch chiếu (Suất chiếu) - CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=15">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        :root {
            --primary-blue: #0284c7;
            --primary-blue-soft: #e0f2fe;
            --success-green: #10b981;
            --success-green-soft: #d1fae5;
            --warning-orange: #f59e0b;
            --warning-orange-soft: #fef3c7;
            --danger-red: #ef4444;
            --danger-red-soft: #fee2e2;
            --purple-badge: #8b5cf6;
            --purple-badge-soft: #ede9fe;
        }

        .page-header-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }
        .search-top-box {
            display: flex;
            align-items: center;
            background: #fff;
            border: 1px solid var(--border-subtle);
            border-radius: 99px;
            padding: 8px 18px;
            width: 320px;
            gap: 10px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.02);
        }
        .search-top-box input {
            border: none;
            outline: none;
            font-size: 13px;
            width: 100%;
            background: transparent;
        }

        /* 5 Thống kê Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 14px;
            margin-bottom: 20px;
        }
        .stat-card-custom {
            background: #fff;
            border-radius: 14px;
            border: 1px solid var(--border-subtle);
            padding: 14px 16px;
            display: flex;
            align-items: center;
            gap: 14px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.02);
        }
        .stat-icon-wrap {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }
        .stat-icon-blue { background: var(--primary-blue-soft); color: var(--primary-blue); }
        .stat-icon-green { background: var(--success-green-soft); color: var(--success-green); }
        .stat-icon-orange { background: var(--warning-orange-soft); color: var(--warning-orange); }
        .stat-icon-red { background: var(--danger-red-soft); color: var(--danger-red); }
        .stat-icon-purple { background: var(--purple-badge-soft); color: var(--purple-badge); }

        .stat-num { font-size: 20px; font-weight: 800; line-height: 1.2; color: var(--text-primary); }
        .stat-txt { font-size: 12px; color: var(--text-muted); font-weight: 500; }

        /* Filter Toolbar Card */
        .filter-panel {
            background: #fff;
            border-radius: 14px;
            border: 1px solid var(--border-subtle);
            padding: 16px 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.02);
        }
        .filter-grid {
            display: grid;
            grid-template-columns: 1.4fr 1.2fr 1.1fr 1fr 1fr auto;
            gap: 12px;
            align-items: flex-end;
        }
        .filter-item label {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 700;
            color: var(--text-secondary);
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .filter-input {
            width: 100%;
            height: 38px;
            padding: 0 10px;
            border: 1px solid var(--border-subtle);
            border-radius: 8px;
            background: var(--bg-input);
            font-size: 12.5px;
            color: var(--text-primary);
            outline: none;
            box-sizing: border-box;
        }
        .filter-input:focus { border-color: var(--pink); background: #fff; }

        /* Badges */
        .format-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
        }
        .format-2d { background: #e0f2fe; color: #0284c7; }
        .format-3d { background: #fef3c7; color: #d97706; }
        .format-imax { background: #ede9fe; color: #7c3aed; }

        .status-dot-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            font-weight: 600;
        }
        .status-dot { width: 7px; height: 7px; border-radius: 50%; }
        .st-active { color: #10b981; }
        .st-active .status-dot { background: #10b981; }
        .st-upcoming { color: #f59e0b; }
        .st-upcoming .status-dot { background: #f59e0b; }
        .st-closed { color: #64748b; }
        .st-closed .status-dot { background: #64748b; }
        .st-cancelled { color: #ef4444; }
        .st-cancelled .status-dot { background: #ef4444; }

        /* Action Buttons */
        .btn-action-icon {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid transparent;
            cursor: pointer;
            font-size: 13px;
            transition: all 0.2s;
            text-decoration: none;
        }
        .btn-edit { background: #eff6ff; color: #2563eb; border-color: #bfdbfe; }
        .btn-edit:hover { background: #2563eb; color: #fff; }
        .btn-cancel { background: #fef2f2; color: #dc2626; border-color: #fecaca; }
        .btn-cancel:hover { background: #dc2626; color: #fff; }
        .btn-view { background: #f8fafc; color: #64748b; border-color: #e2e8f0; }
        .btn-view:hover { background: #64748b; color: #fff; }

        /* Quick Time Slots */
        .quick-time-group {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-top: 8px;
        }
        .btn-time-chip {
            padding: 4px 10px;
            border-radius: 6px;
            border: 1px solid var(--border-subtle);
            background: #fff;
            font-size: 11px;
            font-weight: 700;
            color: var(--text-secondary);
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-time-chip:hover {
            border-color: var(--pink);
            color: var(--pink);
            background: var(--pink-soft);
        }

        .movie-cell {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .movie-thumb {
            width: 34px;
            height: 48px;
            border-radius: 4px;
            object-fit: cover;
            background: #e2e8f0;
            flex-shrink: 0;
        }

        .modal-form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 14px;
        }
        .full-col { grid-column: 1 / -1; }

        /* Pagination Styles */
        .table-pagination-footer {
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
            font-weight: 500;
        }
        .pagination-info strong {
            color: var(--text-primary);
            font-weight: 700;
        }
        .pagination-wrapper {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .page-chip, .page-nav-btn {
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
            user-select: none;
        }
        .page-chip:hover, .page-nav-btn:hover {
            border-color: var(--pink);
            color: var(--pink);
            background: #fff1f2;
        }
        .page-chip.active {
            background: var(--pink);
            border-color: var(--pink);
            color: #ffffff;
            font-weight: 700;
            box-shadow: 0 2px 6px rgba(225, 29, 72, 0.25);
            pointer-events: none;
        }
        .page-nav-btn.disabled {
            opacity: 0.4;
            cursor: not-allowed;
            pointer-events: none;
            background: #f8fafc;
            border-color: #e2e8f0;
            color: #94a3b8;
        }
        .page-dots {
            min-width: 24px;
            text-align: center;
            color: #94a3b8;
            font-weight: 700;
            font-size: 14px;
            letter-spacing: 1px;
        }
        .page-size-select {
            height: 34px;
            padding: 0 8px;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
            background: #ffffff;
            font-size: 12.5px;
            color: #475569;
            font-weight: 600;
            outline: none;
            cursor: pointer;
            transition: border-color 0.2s;
        }
        .page-size-select:focus {
            border-color: var(--pink);
        }

        /* TIMELINE LỊCH PHÒNG CHIẾU */
        .timeline-container {
            padding: 20px;
            display: flex;
            flex-direction: column;
            gap: 16px;
            background: #f8fafc;
        }
        .timeline-room-card {
            background: #ffffff;
            border: 1px solid var(--border-subtle);
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
            transition: box-shadow 0.2s;
        }
        .timeline-room-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }
        .timeline-room-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 18px;
            background: #ffffff;
            border-bottom: 1px solid #f1f5f9;
        }
        .timeline-room-icon {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: #e0f2fe;
            color: #0284c7;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
        }
        .timeline-slots-track {
            padding: 16px 18px;
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
            background: #fafbfc;
            min-height: 80px;
            align-items: center;
        }
        .timeline-slot-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 12px 14px;
            width: 220px;
            flex-shrink: 0;
            box-shadow: 0 1px 3px rgba(0,0,0,0.03);
            transition: all 0.2s ease;
            position: relative;
        }
        .timeline-slot-card:hover {
            border-color: #0284c7;
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(2, 132, 199, 0.12);
        }
        .slot-time-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            color: #0284c7;
            background: #f0f9ff;
            border: 1px solid #bae6fd;
            padding: 3px 8px;
            border-radius: 6px;
            margin-bottom: 8px;
        }
        .slot-movie-title {
            font-size: 13.5px;
            font-weight: 700;
            color: #0f172a;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin-bottom: 6px;
        }
        .slot-meta {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 8px;
        }
        .slot-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-top: 1px dashed #f1f5f9;
            padding-top: 8px;
            margin-top: 4px;
        }
        .timeline-empty-room {
            color: #94a3b8;
            font-size: 13px;
            font-style: italic;
            display: flex;
            align-items: center;
            padding: 10px 4px;
        }
        .btn-range {
            transition: all 0.2s ease;
        }
        .btn-range:hover {
            background: #fff1f2 !important;
            color: var(--pink) !important;
        }

        /* Responsive cho Lịch chiếu */
        @media (max-width: 1200px) {
            .stats-grid {
                grid-template-columns: repeat(3, 1fr);
            }
            .filter-grid {
                grid-template-columns: repeat(3, 1fr);
            }
        }
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .filter-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<div class="app-shell">

    <!-- MENU BÊN TRÁI ĐỒNG BỘ -->
    <c:choose>
        <c:when test="${sessionScope.userRole == 'NhanVien' || sessionScope.userRole == 'Nhân viên'}">
            <jsp:include page="/menunv.jsp" />
        </c:when>
        <c:otherwise>
            <jsp:include page="/menuadmin.jsp" />
        </c:otherwise>
    </c:choose>

    <!-- MAIN CONTENT WRAPPER -->
    <div class="main-wrapper" style="flex: 1; padding: 24px; background: #f8fafc; overflow-y: auto;">

        <!-- TOP BAR: Search & Action -->
        <div class="page-header-row">
            <div style="display: flex; align-items: center; gap: 14px;">
                <div style="width: 44px; height: 44px; border-radius: 12px; background: #fff; border: 1px solid var(--border-subtle); display: flex; align-items: center; justify-content: center; font-size: 20px; color: var(--pink);">
                    🎬
                </div>
                <div>
                    <h1 style="font-size: 20px; font-weight: 800; margin: 0; color: var(--text-primary);">Quản lý Lịch chiếu (Suất chiếu)</h1>
                    <p style="font-size: 12px; color: var(--text-muted); margin: 3px 0 0;">Quản lý, theo dõi và điều chỉnh lịch chiếu phim tại rạp</p>
                </div>
            </div>

            <div style="display: flex; align-items: center; gap: 12px;">
                <form action="${pageContext.request.contextPath}/suat-chieu/view" method="GET" class="search-top-box">
                    <i class="fa-solid fa-magnifying-glass" style="color: #94a3b8; font-size: 13px;"></i>
                    <input type="text" name="keyword" value="${filterKeyword}" placeholder="Tìm kiếm phim, phòng chiếu...">
                </form>
                <button type="button" class="btn btn-pink" style="height: 42px; border-radius: 10px; font-weight: 700; display: inline-flex; align-items: center; gap: 8px;" onclick="openAddSuatChieu()">
                    <i class="fa-solid fa-plus"></i> Thêm suất chiếu
                </button>
            </div>
        </div>

        <!-- 5 THỐNG KÊ CARDS -->
        <div class="stats-grid">
            <div class="stat-card-custom">
                <div class="stat-icon-wrap stat-icon-blue"><i class="fa-solid fa-film"></i></div>
                <div>
                    <div class="stat-num">${statTotal}</div>
                    <div class="stat-txt">Tổng suất chiếu</div>
                </div>
            </div>
            <div class="stat-card-custom">
                <div class="stat-icon-wrap stat-icon-green"><i class="fa-solid fa-ticket"></i></div>
                <div>
                    <div class="stat-num" style="color: var(--success-green);">${statActive}</div>
                    <div class="stat-txt">Đang mở bán</div>
                </div>
            </div>
            <div class="stat-card-custom">
                <div class="stat-icon-wrap stat-icon-orange"><i class="fa-regular fa-clock"></i></div>
                <div>
                    <div class="stat-num" style="color: var(--warning-orange);">${statUpcoming}</div>
                    <div class="stat-txt">Sắp diễn ra</div>
                </div>
            </div>
            <div class="stat-card-custom">
                <div class="stat-icon-wrap stat-icon-red"><i class="fa-solid fa-ban"></i></div>
                <div>
                    <div class="stat-num" style="color: var(--danger-red);">${statCancelled}</div>
                    <div class="stat-txt">Đã hủy</div>
                </div>
            </div>
            <div class="stat-card-custom">
                <div class="stat-icon-wrap stat-icon-purple"><i class="fa-solid fa-chart-simple"></i></div>
                <div>
                    <div class="stat-num" style="color: var(--purple-badge);">${statRate}</div>
                    <div class="stat-txt">Tỷ lệ lấp đầy TB</div>
                </div>
            </div>
        </div>

        <!-- BỘ LỌC TÌM KIẾM -->
        <form action="${pageContext.request.contextPath}/suat-chieu/view" method="GET" class="filter-panel" id="filterForm" onsubmit="document.getElementById('pageNumberInput').value = 1;">
            <input type="hidden" name="page" id="pageNumberInput" value="${currentPage}">
            <input type="hidden" name="pageSize" id="pageSizeInput" value="${pageSize}">
            <c:if test="${not empty filterKeyword}">
                <input type="hidden" name="keyword" value="${filterKeyword}">
            </c:if>
            <div class="filter-grid">
                <div class="filter-item">
                    <label><i class="fa-regular fa-calendar"></i> Ngày chiếu</label>
                    <div style="display: flex; gap: 6px;">
                        <input type="date" name="tuNgay" id="filterTuNgay" value="${filterTuNgay}" class="filter-input" title="Từ ngày">
                        <input type="date" name="denNgay" id="filterDenNgay" value="${filterDenNgay}" class="filter-input" title="Đến ngày">
                    </div>
                </div>

                <div class="filter-item">
                    <label><i class="fa-solid fa-clapperboard"></i> Phim</label>
                    <select name="maPhim" class="filter-input">
                        <option value="">Tất cả phim</option>
                        <c:forEach items="${listPhim}" var="p">
                            <option value="${p.maPhim}" ${p.maPhim == filterMaPhim ? 'selected' : ''}>${p.tenPhim}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="filter-item">
                    <label><i class="fa-solid fa-door-open"></i> Phòng chiếu</label>
                    <select name="maPhong" class="filter-input">
                        <option value="">Tất cả phòng</option>
                        <c:forEach items="${listPhong}" var="pc">
                            <option value="${pc.maPhong}" ${pc.maPhong == filterMaPhong ? 'selected' : ''}>${pc.tenPhong}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="filter-item">
                    <label><i class="fa-solid fa-tag"></i> Định dạng</label>
                    <select name="dinhDang" class="filter-input">
                        <option value="">Tất cả định dạng</option>
                        <option value="2D" ${filterDinhDang == '2D' ? 'selected' : ''}>2D</option>
                        <option value="3D" ${filterDinhDang == '3D' ? 'selected' : ''}>3D</option>
                        <option value="IMAX" ${filterDinhDang == 'IMAX' ? 'selected' : ''}>IMAX</option>
                    </select>
                </div>

                <div class="filter-item">
                    <label><i class="fa-regular fa-circle-dot"></i> Trạng thái</label>
                    <select name="trangThai" class="filter-input">
                        <option value="">Tất cả trạng thái</option>
                        <option value="Đang mở bán" ${filterTrangThai == 'Đang mở bán' ? 'selected' : ''}>Đang mở bán</option>
                        <option value="Sắp diễn ra" ${filterTrangThai == 'Sắp diễn ra' ? 'selected' : ''}>Sắp diễn ra</option>
                        <option value="Đã đóng bán" ${filterTrangThai == 'Đã đóng bán' ? 'selected' : ''}>Đã đóng bán</option>
                        <option value="Đã hủy" ${filterTrangThai == 'Đã hủy' ? 'selected' : ''}>Đã hủy</option>
                    </select>
                </div>

                <div style="display: flex; gap: 8px;">
                    <button type="submit" class="btn btn-pink" style="height: 38px; border-radius: 8px; font-weight: 700; padding: 0 16px;">
                        <i class="fa-solid fa-magnifying-glass"></i> Tìm kiếm
                    </button>
                    <a href="${pageContext.request.contextPath}/suat-chieu/view" class="btn btn-outline" style="height: 38px; border-radius: 8px; padding: 0 12px; display: inline-flex; align-items: center; justify-content: center;">
                        <i class="fa-solid fa-rotate-left"></i>
                    </a>
                </div>
            </div>
        </form>

        <!-- THÔNG BÁO LỖI NGOÀI NẾU CÓ -->
        <c:if test="${not empty errorMessage and openModal == null}">
            <div class="alert-error" style="margin-bottom: 20px;">
                ⚠️ <c:out value="${errorMessage}"/>
            </div>
        </c:if>

        <!-- BẢNG DANH SÁCH LỊCH CHIẾU -->
        <div style="background: #fff; border-radius: 14px; border: 1px solid var(--border-subtle); overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.02);">
            
            <!-- Tab Header: Danh sách vs Lịch phòng chiếu -->
            <div style="display: flex; align-items: center; justify-content: space-between; padding: 14px 20px; border-bottom: 1px solid var(--border-subtle); background: #fafbfc;">
                <div style="display: flex; gap: 8px;">
                    <button type="button" id="btnTabList" onclick="switchViewMode('list')" class="btn btn-pink btn-sm" style="border-radius: 8px; font-weight: 700; cursor: pointer;">
                        <i class="fa-solid fa-list-ul"></i> Danh sách
                    </button>
                    <button type="button" id="btnTabTimeline" onclick="switchViewMode('timeline')" class="btn btn-outline btn-sm" style="border-radius: 8px; background: #fff; font-weight: 700; cursor: pointer;">
                        <i class="fa-regular fa-calendar-days"></i> Lịch phòng chiếu
                    </button>
                </div>

                <div style="display: flex; border: 1px solid var(--border-subtle); border-radius: 8px; overflow: hidden; background: #fff;">
                    <button type="button" id="btnDateToday" onclick="setDateFilter('today')" class="btn-range" style="border: none; background: var(--pink); color: #fff; padding: 5px 14px; font-size: 11px; font-weight: 700; cursor: pointer;">Ngày</button>
                    <button type="button" id="btnDateWeek" onclick="setDateFilter('week')" class="btn-range" style="border: none; background: transparent; padding: 5px 14px; font-size: 11px; font-weight: 600; color: var(--text-secondary); cursor: pointer;">Tuần</button>
                    <button type="button" id="btnDateMonth" onclick="setDateFilter('month')" class="btn-range" style="border: none; background: transparent; padding: 5px 14px; font-size: 11px; font-weight: 600; color: var(--text-secondary); cursor: pointer;">Tháng</button>
                </div>
            </div>

            <!-- 1. GIAO DIỆN DẠNG BẢNG DANH SÁCH -->
            <div id="viewListContainer">

            <!-- Table -->
            <%
                int pSize = 10;
                try {
                    if (request.getAttribute("pageSize") != null) {
                        pSize = Integer.parseInt(request.getAttribute("pageSize").toString());
                    } else if (request.getParameter("pageSize") != null) {
                        pSize = Integer.parseInt(request.getParameter("pageSize"));
                    }
                } catch (Exception ignored) {}
                if (pSize <= 0) pSize = 10;

                int totalRecs = 0;
                if (request.getAttribute("totalItems") != null) {
                    totalRecs = Integer.parseInt(request.getAttribute("totalItems").toString());
                } else if (request.getAttribute("listSuatChieu") != null) {
                    totalRecs = ((java.util.List<?>) request.getAttribute("listSuatChieu")).size();
                }

                int tPages = (int) Math.ceil((double) totalRecs / pSize);
                if (tPages <= 0) tPages = 1;

                int curPage = 1;
                try {
                    if (request.getAttribute("currentPage") != null) {
                        curPage = Integer.parseInt(request.getAttribute("currentPage").toString());
                    } else if (request.getParameter("page") != null) {
                        curPage = Integer.parseInt(request.getParameter("page"));
                    }
                } catch (Exception ignored) {}
                if (curPage < 1) curPage = 1;
                if (curPage > tPages) curPage = tPages;

                int sliceStart = (curPage - 1) * pSize;
                int sliceEnd = Math.min(sliceStart + pSize, totalRecs);

                int dispFrom = totalRecs > 0 ? (sliceStart + 1) : 0;
                int dispTo = sliceEnd;

                boolean isServerPaged = (request.getAttribute("totalItems") != null && totalRecs > 0 
                        && request.getAttribute("listSuatChieu") != null 
                        && ((java.util.List<?>) request.getAttribute("listSuatChieu")).size() <= pSize);

                pageContext.setAttribute("pageSize", pSize);
                pageContext.setAttribute("totalRecords", totalRecs);
                pageContext.setAttribute("totalPages", tPages);
                pageContext.setAttribute("currentPage", curPage);
                pageContext.setAttribute("sliceStart", sliceStart);
                pageContext.setAttribute("sliceEnd", sliceEnd);
                pageContext.setAttribute("dispFrom", dispFrom);
                pageContext.setAttribute("dispTo", dispTo);
                pageContext.setAttribute("isServerPaged", isServerPaged);
            %>

            <table class="data-table" style="width: 100%; margin: 0;">
                <thead>
                <tr style="background: #f8fafc; border-bottom: 1px solid var(--border-subtle);">
                    <th style="width: 50px; text-align: center;">#</th>
                    <th style="width: 90px;">Mã suất</th>
                    <th>Tên phim</th>
                    <th>Phòng chiếu</th>
                    <th>Định dạng</th>
                    <th>Ngày chiếu</th>
                    <th>Giờ chiếu</th>
                    <th>Thời lượng</th>
                    <th>Trạng thái</th>
                    <th>Giá cơ bản</th>
                    <th style="text-align: right; width: 110px;">Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${listSuatChieu}" var="sc" varStatus="loop">
                    <c:if test="${isServerPaged or (loop.index >= sliceStart and loop.index < sliceEnd)}">
                    <tr>
                        <td style="text-align: center; color: var(--text-muted); font-weight: 600;">${isServerPaged ? ((currentPage - 1) * pageSize + loop.count) : (loop.index + 1)}</td>
                        <td><strong style="color: #0284c7;">${sc.maSuatFormatted}</strong></td>
                        <td>
                            <div class="movie-cell">
                                <c:choose>
                                    <c:when test="${not empty sc.phim.poster}">
                                        <img src="${pageContext.request.contextPath}/assets/images/${sc.phim.poster}" class="movie-thumb" alt="Poster" onerror="this.src='https://placehold.co/34x48?text=FILM'">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="movie-thumb" style="display: flex; align-items: center; justify-content: center; font-size: 10px; color: #94a3b8;">FILM</div>
                                    </c:otherwise>
                                </c:choose>
                                <div>
                                    <strong style="color: var(--text-primary); font-size: 13.5px;"><c:out value="${sc.phim.tenPhim}"/></strong>
                                    <div style="font-size: 11px; color: var(--text-muted);">${sc.phim.doTuoi != null ? sc.phim.doTuoi : 'P'}</div>
                                </div>
                            </div>
                        </td>
                        <td><strong style="color: #334155;"><c:out value="${sc.phongChieu.tenPhong}"/></strong></td>
                        <td>
                            <c:choose>
                                <c:when test="${sc.dinhDang == '3D'}"><span class="format-badge format-3d">3D</span></c:when>
                                <c:when test="${sc.dinhDang == 'IMAX'}"><span class="format-badge format-imax">IMAX</span></c:when>
                                <c:otherwise><span class="format-badge format-2d">2D</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>${sc.ngayChieu}</td>
                        <td>
                            <strong style="color: #0f172a;">${sc.gioBatDau}</strong>
                            <span style="color: var(--text-muted); font-size: 11px;">-</span>
                            <span style="color: #64748b;">${sc.gioKetThuc}</span>
                        </td>
                        <td>${sc.phim.thoiLuong} phút</td>
                        <td>
                            <c:choose>
                                <c:when test="${sc.trangThai == 'Đang mở bán'}">
                                    <span class="status-dot-badge st-active"><span class="status-dot"></span> Đang mở bán</span>
                                </c:when>
                                <c:when test="${sc.trangThai == 'Sắp diễn ra'}">
                                    <span class="status-dot-badge st-upcoming"><span class="status-dot"></span> Sắp diễn ra</span>
                                </c:when>
                                <c:when test="${sc.trangThai == 'Đã hủy'}">
                                    <span class="status-dot-badge st-cancelled"><span class="status-dot"></span> Đã hủy</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-dot-badge st-closed"><span class="status-dot"></span> ${sc.trangThai}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <strong style="color: #059669;">
                                <fmt:formatNumber value="${sc.giaVeCoBan != null ? sc.giaVeCoBan : 80000}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </strong>
                        </td>
                        <td style="text-align: right;">
                            <div style="display: inline-flex; gap: 4px;">
                                <a href="${pageContext.request.contextPath}/suat-chieu/view-update?id=${sc.maSuat}"
                                   class="btn-action-icon btn-edit" title="Sửa thông tin"
                                   data-id="${sc.maSuat}"
                                   data-code="${sc.maSuatFormatted}"
                                   data-phim="${sc.phim.maPhim}"
                                   data-phong="${sc.phongChieu.maPhong}"
                                   data-dinhdang="${sc.dinhDang}"
                                   data-ngay="${sc.ngayChieu}"
                                   data-gio="${sc.gioBatDau}"
                                   data-gia="${sc.giaVeCoBan}"
                                   data-trangthai="${sc.trangThai}"
                                   onclick="event.preventDefault(); openEditSuatChieuFromBtn(this)">
                                    <i class="fa-solid fa-pen"></i>
                                </a>
                                
                                <c:if test="${sc.trangThai != 'Đã hủy'}">
                                    <button type="button" class="btn-action-icon btn-cancel" title="Hủy suất chiếu (Không xóa)"
                                            data-id="${sc.maSuat}"
                                            data-code="${sc.maSuatFormatted}"
                                            data-tenphim="<c:out value='${sc.phim.tenPhim}'/>"
                                            onclick="openCancelModalFromBtn(this)">
                                        <i class="fa-solid fa-ban"></i>
                                    </button>
                                </c:if>

                                <a href="${pageContext.request.contextPath}/suat-chieu/detail?id=${sc.maSuat}"
                                   class="btn-action-icon btn-view" title="Xem chi tiết"
                                   data-id="${sc.maSuat}"
                                   data-code="${sc.maSuatFormatted}"
                                   data-phim="<c:out value='${sc.phim.tenPhim}'/>"
                                   data-phong="<c:out value='${sc.phongChieu.tenPhong}'/>"
                                   data-dinhdang="${sc.dinhDang}"
                                   data-ngay="${sc.ngayChieu}"
                                   data-gio="${sc.gioBatDau} - ${sc.gioKetThuc}"
                                   data-thoiluong="${sc.phim.thoiLuong} phút"
                                   data-gia="<fmt:formatNumber value='${sc.giaVeCoBan}' type='currency' currencySymbol='đ' maxFractionDigits='0'/>"
                                   data-trangthai="${sc.trangThai}"
                                   data-lydo="<c:out value='${sc.lyDoHuy}'/>"
                                   onclick="event.preventDefault(); openDetailSuatChieuFromBtn(this)">
                                    <i class="fa-regular fa-eye"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                    </c:if>
                </c:forEach>
                <c:if test="${empty listSuatChieu}">
                    <tr>
                        <td colspan="11" style="text-align: center; padding: 48px; color: var(--text-muted);">
                            <div style="font-size: 36px; margin-bottom: 8px;">🎬</div>
                            <div>Không tìm thấy suất chiếu nào phù hợp.</div>
                        </td>
                    </tr>
                </c:if>
                </tbody>
            </table>

            <!-- Phân trang (Pagination) -->
            <div class="table-pagination-footer">
                <div class="pagination-info">
                    Hiển thị <strong>${dispFrom}</strong> - <strong>${dispTo}</strong> trong tổng số <strong>${totalRecords}</strong> suất chiếu
                </div>

                <div style="display: flex; align-items: center; gap: 14px; flex-wrap: wrap;">
                    <div style="display: flex; align-items: center; gap: 6px;">
                        <span style="font-size: 12px; color: var(--text-muted); font-weight: 500;">Hiển thị:</span>
                        <select class="page-size-select" onchange="changePageSize(this.value)">
                            <option value="10" ${pageSize == 10 ? 'selected' : ''}>10 / trang</option>
                            <option value="20" ${pageSize == 20 ? 'selected' : ''}>20 / trang</option>
                            <option value="50" ${pageSize == 50 ? 'selected' : ''}>50 / trang</option>
                        </select>
                    </div>

                    <c:url var="basePageUrl" value="/suat-chieu/view">
                        <c:if test="${not empty filterMaPhim}"><c:param name="maPhim" value="${filterMaPhim}"/></c:if>
                        <c:if test="${not empty filterMaPhong}"><c:param name="maPhong" value="${filterMaPhong}"/></c:if>
                        <c:if test="${not empty filterDinhDang}"><c:param name="dinhDang" value="${filterDinhDang}"/></c:if>
                        <c:if test="${not empty filterTrangThai}"><c:param name="trangThai" value="${filterTrangThai}"/></c:if>
                        <c:if test="${not empty filterTuNgay}"><c:param name="tuNgay" value="${filterTuNgay}"/></c:if>
                        <c:if test="${not empty filterDenNgay}"><c:param name="denNgay" value="${filterDenNgay}"/></c:if>
                        <c:if test="${not empty filterKeyword}"><c:param name="keyword" value="${filterKeyword}"/></c:if>
                        <c:if test="${pageSize != 10}"><c:param name="pageSize" value="${pageSize}"/></c:if>
                    </c:url>

                    <div class="pagination-wrapper">
                        <!-- Nút Trang đầu « -->
                        <c:choose>
                            <c:when test="${currentPage > 1}">
                                <a href="${basePageUrl}${basePageUrl.contains('?') ? '&' : '?'}page=1"
                                   onclick="event.preventDefault(); changePage(1);"
                                   class="page-nav-btn" title="Trang đầu">
                                    <i class="fa-solid fa-angles-left"></i>
                                </a>
                                <a href="${basePageUrl}${basePageUrl.contains('?') ? '&' : '?'}page=${currentPage - 1}"
                                   onclick="event.preventDefault(); changePage(${currentPage - 1});"
                                   class="page-nav-btn" title="Trang trước">
                                    <i class="fa-solid fa-angle-left"></i>
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span class="page-nav-btn disabled" title="Trang đầu"><i class="fa-solid fa-angles-left"></i></span>
                                <span class="page-nav-btn disabled" title="Trang trước"><i class="fa-solid fa-angle-left"></i></span>
                            </c:otherwise>
                        </c:choose>

                        <!-- Danh sách các nút số trang 1, 2, ... -->
                        <c:choose>
                            <c:when test="${totalPages <= 7}">
                                <c:forEach var="p" begin="1" end="${totalPages}">
                                    <a href="${basePageUrl}${basePageUrl.contains('?') ? '&' : '?'}page=${p}"
                                       onclick="event.preventDefault(); changePage(${p});"
                                       class="page-chip ${p == currentPage ? 'active' : ''}">${p}</a>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <a href="${basePageUrl}${basePageUrl.contains('?') ? '&' : '?'}page=1"
                                   onclick="event.preventDefault(); changePage(1);"
                                   class="page-chip ${1 == currentPage ? 'active' : ''}">1</a>

                                <c:if test="${currentPage > 4}">
                                    <span class="page-dots">...</span>
                                </c:if>

                                <c:set var="startPage" value="${currentPage - 1 > 2 ? currentPage - 1 : 2}"/>
                                <c:set var="endPage" value="${currentPage + 1 < totalPages - 1 ? currentPage + 1 : totalPages - 1}"/>
                                <c:if test="${startPage <= endPage}">
                                    <c:forEach var="p" begin="${startPage}" end="${endPage}">
                                        <a href="${basePageUrl}${basePageUrl.contains('?') ? '&' : '?'}page=${p}"
                                           onclick="event.preventDefault(); changePage(${p});"
                                           class="page-chip ${p == currentPage ? 'active' : ''}">${p}</a>
                                    </c:forEach>
                                </c:if>

                                <c:if test="${currentPage < totalPages - 3}">
                                    <span class="page-dots">...</span>
                                </c:if>

                                <a href="${basePageUrl}${basePageUrl.contains('?') ? '&' : '?'}page=${totalPages}"
                                   onclick="event.preventDefault(); changePage(${totalPages});"
                                   class="page-chip ${totalPages == currentPage ? 'active' : ''}">${totalPages}</a>
                            </c:otherwise>
                        </c:choose>

                        <!-- Nút Trang kế tiếp & Trang cuối » -->
                        <c:choose>
                            <c:when test="${currentPage < totalPages}">
                                <a href="${basePageUrl}${basePageUrl.contains('?') ? '&' : '?'}page=${currentPage + 1}"
                                   onclick="event.preventDefault(); changePage(${currentPage + 1});"
                                   class="page-nav-btn" title="Trang kế tiếp">
                                    <i class="fa-solid fa-angle-right"></i>
                                </a>
                                <a href="${basePageUrl}${basePageUrl.contains('?') ? '&' : '?'}page=${totalPages}"
                                   onclick="event.preventDefault(); changePage(${totalPages});"
                                   class="page-nav-btn" title="Trang cuối">
                                    <i class="fa-solid fa-angles-right"></i>
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span class="page-nav-btn disabled" title="Trang kế tiếp"><i class="fa-solid fa-angle-right"></i></span>
                                <span class="page-nav-btn disabled" title="Trang cuối"><i class="fa-solid fa-angles-right"></i></span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            </div> <!-- /#viewListContainer -->

            <!-- 2. GIAO DIỆN DẠNG LỊCH PHÒNG CHIẾU (TIMELINE THEO PHÒNG) -->
            <div id="viewTimelineContainer" class="timeline-container" style="display: none;">
                <c:choose>
                    <c:when test="${empty listPhong}">
                        <div style="text-align: center; padding: 40px; color: #94a3b8;">
                            <i class="fa-solid fa-door-closed" style="font-size: 32px; margin-bottom: 8px; display: block;"></i>
                            Chưa có dữ liệu phòng chiếu trong hệ thống.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${listPhong}" var="pc">
                            <div class="timeline-room-card">
                                <div class="timeline-room-header">
                                    <div style="display: flex; align-items: center; gap: 12px;">
                                        <div class="timeline-room-icon">
                                            <i class="fa-solid fa-door-open"></i>
                                        </div>
                                        <div>
                                            <h4 style="margin: 0; font-size: 14.5px; font-weight: 700; color: #0f172a;">
                                                ${pc.tenPhong}
                                            </h4>
                                            <div style="display: flex; gap: 8px; align-items: center; margin-top: 3px;">
                                                <span style="font-size: 12px; color: #64748b;">
                                                    <i class="fa-solid fa-chair" style="color: #94a3b8;"></i> ${pc.sucChua} ghế
                                                </span>
                                                <span class="format-badge ${pc.loaiPhong == 'IMAX' ? 'format-imax' : (pc.loaiPhong == '3D' ? 'format-3d' : 'format-2d')}" style="font-size: 10.5px; padding: 2px 7px;">
                                                    ${pc.loaiPhong}
                                                </span>
                                            </div>
                                        </div>
                                    </div>

                                    <div>
                                        <button type="button" class="btn btn-outline btn-sm" onclick="openAddSuatChieuForRoom('${pc.maPhong}', '${pc.loaiPhong}')" style="font-size: 12px; border-radius: 8px; font-weight: 600;">
                                            <i class="fa-solid fa-plus" style="margin-right: 4px; color: var(--pink);"></i> Thêm suất chiếu
                                        </button>
                                    </div>
                                </div>

                                <!-- Danh sách suất chiếu theo phòng -->
                                <div class="timeline-slots-track">
                                    <c:set var="countInRoom" value="0" />
                                    <c:forEach items="${allSuatChieu != null ? allSuatChieu : listSuatChieu}" var="sc">
                                        <c:if test="${sc.phongChieu.maPhong == pc.maPhong}">
                                            <c:set var="countInRoom" value="${countInRoom + 1}" />
                                            <div class="timeline-slot-card">
                                                <div class="slot-time-badge">
                                                    <i class="fa-regular fa-clock"></i>
                                                    <strong>${sc.gioBatDau.toString().length() > 5 ? sc.gioBatDau.toString().substring(0, 5) : sc.gioBatDau}</strong>
                                                    <span> - </span>
                                                    <span>${sc.gioKetThuc.toString().length() > 5 ? sc.gioKetThuc.toString().substring(0, 5) : sc.gioKetThuc}</span>
                                                </div>

                                                <div class="slot-movie-title" title="${sc.phim.tenPhim}">
                                                    ${sc.phim.tenPhim}
                                                </div>

                                                <div class="slot-meta">
                                                    <span class="format-badge ${sc.dinhDang == 'IMAX' ? 'format-imax' : (sc.dinhDang == '3D' ? 'format-3d' : 'format-2d')}" style="font-size: 10px; padding: 2px 6px;">
                                                        ${sc.dinhDang}
                                                    </span>
                                                    <span style="font-size: 11.5px; color: #64748b; font-weight: 500;">
                                                        <i class="fa-regular fa-calendar" style="margin-right: 3px;"></i>${sc.ngayChieu}
                                                    </span>
                                                </div>

                                                <div class="slot-footer">
                                                    <span class="status-dot-badge ${sc.trangThai == 'Đang mở bán' ? 'status-active' : (sc.trangThai == 'Đã hủy' ? 'status-cancelled' : 'status-upcoming')}" style="font-size: 10.5px; padding: 2px 7px;">
                                                        ${sc.trangThai}
                                                    </span>

                                                    <div style="display: flex; gap: 4px;">
                                                        <button type="button" class="action-btn action-view" title="Xem chi tiết"
                                                                data-code="${sc.maSuatFormatted}"
                                                                data-phim="${sc.phim.tenPhim} (${sc.phim.thoiLuong} phút)"
                                                                data-phong="${sc.phongChieu.tenPhong} (${sc.phongChieu.sucChua} ghế)"
                                                                data-dinhdang="${sc.dinhDang}"
                                                                data-ngay="${sc.ngayChieu}"
                                                                data-gio="${sc.gioBatDau} - ${sc.gioKetThuc}"
                                                                data-gia="${sc.giaVeCoBan}"
                                                                data-trangthai="${sc.trangThai}"
                                                                data-lydo="${sc.lyDoHuy}"
                                                                onclick="openDetailSuatChieuFromBtn(this)">
                                                            <i class="fa-regular fa-eye"></i>
                                                        </button>
                                                        <button type="button" class="action-btn action-edit" title="Chỉnh sửa"
                                                                data-id="${sc.maSuat}"
                                                                data-code="${sc.maSuatFormatted}"
                                                                data-phim="${sc.phim.maPhim}"
                                                                data-phong="${sc.phongChieu.maPhong}"
                                                                data-dinhdang="${sc.dinhDang}"
                                                                data-ngay="${sc.ngayChieu}"
                                                                data-gio="${sc.gioBatDau}"
                                                                data-gia="${sc.giaVeCoBan}"
                                                                data-trangthai="${sc.trangThai}"
                                                                onclick="openEditSuatChieuFromBtn(this)">
                                                            <i class="fa-solid fa-pen"></i>
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:if>
                                    </c:forEach>

                                    <c:if test="${countInRoom == 0}">
                                        <div class="timeline-empty-room">
                                            <i class="fa-regular fa-calendar-xmark" style="margin-right: 6px; font-size: 14px;"></i>
                                            Chưa có suất chiếu nào cho phòng này trong khoảng thời gian đã chọn.
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div> <!-- /#viewTimelineContainer -->
        </div>
    </div>
</div>

<!-- ================= MODAL 1: THÊM SUẤT CHIẾU ================= -->
<div class="modal-backdrop ${openModal == 'add' ? 'open' : ''}" id="addSuatChieuModal">
    <div class="modal-box modal-lg" style="max-width: 620px;">
        <div class="modal-header">
            <h3>Thêm Suất Chiếu Mới</h3>
            <button type="button" class="modal-close" onclick="closeModal('addSuatChieuModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'add' and not empty errorMessage}">
            <div class="alert-error" id="addSuatChieuError" style="margin-bottom: 16px;"><c:out value="${errorMessage}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/suat-chieu/add" method="POST">
            <div class="modal-form-grid">
                <div class="form-group full-col">
                    <label>Bộ Phim <span class="required-star">*</span></label>
                    <select id="addMaPhim" name="maPhim" class="form-control" required onchange="calculateEndTime('add')">
                        <option value="">-- Chọn phim đang chiếu --</option>
                        <c:forEach items="${listPhimDangChieu}" var="p">
                            <option value="${p.maPhim}" data-duration="${p.thoiLuong}" ${p.maPhim == rawMaPhim ? 'selected' : ''}>
                                ${p.tenPhim} (${p.thoiLuong} phút)
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label>Phòng chiếu <span class="required-star">*</span></label>
                    <select id="addMaPhong" name="maPhong" class="form-control" required onchange="onPhongChange('add')">
                        <option value="">-- Chọn phòng chiếu --</option>
                        <c:forEach items="${listPhong}" var="pc">
                            <option value="${pc.maPhong}" data-loai="${pc.loaiPhong}" ${pc.maPhong == rawMaPhong ? 'selected' : ''}>
                                ${pc.tenPhong} (${pc.sucChua} ghế - ${pc.loaiPhong})
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label>Định dạng chiếu <span class="required-star">*</span></label>
                    <select id="addDinhDang" name="dinhDang" class="form-control">
                        <option value="2D" ${formSc.dinhDang == '2D' ? 'selected' : ''}>2D</option>
                        <option value="3D" ${formSc.dinhDang == '3D' ? 'selected' : ''}>3D</option>
                        <option value="IMAX" ${formSc.dinhDang == 'IMAX' ? 'selected' : ''}>IMAX</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Ngày chiếu <span class="required-star">*</span></label>
                    <input type="date" id="addNgayChieu" name="ngayChieu" class="form-control" value="${rawNgayChieu}" required>
                </div>

                <div class="form-group">
                    <label>Thời gian dọn dẹp (phút)</label>
                    <input type="number" id="addThoiGianDonDep" name="thoiGianDonDep" class="form-control" value="${rawThoiGianDonDep != null ? rawThoiGianDonDep : '15'}" min="0" max="60" onchange="calculateEndTime('add')" placeholder="15">
                </div>

                <div class="form-group">
                    <label>Giờ bắt đầu (24h) <span class="required-star">*</span></label>
                    <input type="time" id="addGioBatDau" name="gioBatDau" class="form-control" value="${rawGioBatDau}" required onchange="calculateEndTime('add')">
                    <!-- CHỌN NHANH KHUNG GIỜ -->
                    <div class="quick-time-group">
                        <span class="btn-time-chip" onclick="setTime('add', '09:00')">09:00</span>
                        <span class="btn-time-chip" onclick="setTime('add', '12:00')">12:00</span>
                        <span class="btn-time-chip" onclick="setTime('add', '14:30')">14:30</span>
                        <span class="btn-time-chip" onclick="setTime('add', '18:00')">18:00</span>
                        <span class="btn-time-chip" onclick="setTime('add', '20:30')">20:30</span>
                        <span class="btn-time-chip" onclick="setTime('add', '22:15')">22:15</span>
                    </div>
                </div>

                <div class="form-group">
                    <label>Giờ kết thúc dự kiến</label>
                    <input type="text" id="addGioKetThucDisplay" class="form-control" value="Tự động tính (+15p dọn dẹp)" readonly style="background: #f1f5f9; color: #475569; font-weight: 600;">
                </div>

                <div class="form-group">
                    <label>Giá vé cơ bản (VNĐ) <span class="required-star">*</span></label>
                    <input type="number" id="addGiaVeCoBan" name="giaVeCoBan" class="form-control" value="${formSc.giaVeCoBan != null ? formSc.giaVeCoBan : '80000'}" step="5000" min="40000" required>
                </div>

                <div class="form-group full-col">
                    <label>Trạng thái suất chiếu</label>
                    <select id="addTrangThai" name="trangThai" class="form-control">
                        <option value="Đang mở bán" ${formSc.trangThai == 'Đang mở bán' ? 'selected' : ''}>Đang mở bán</option>
                        <option value="Sắp diễn ra" ${formSc.trangThai == 'Sắp diễn ra' ? 'selected' : ''}>Sắp diễn ra</option>
                        <option value="Đã đóng bán" ${formSc.trangThai == 'Đã đóng bán' ? 'selected' : ''}>Đã đóng bán</option>
                    </select>
                </div>
            </div>

            <div class="modal-footer" style="margin-top: 20px;">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addSuatChieuModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Lưu suất chiếu</button>
            </div>
        </form>
    </div>
</div>

<!-- ================= MODAL 2: CẬP NHẬT SUẤT CHIẾU ================= -->
<div class="modal-backdrop ${openModal == 'update' ? 'open' : ''}" id="editSuatChieuModal">
    <div class="modal-box modal-lg" style="max-width: 620px;">
        <div class="modal-header">
            <h3>Cập Nhật Suất Chiếu</h3>
            <button type="button" class="modal-close" onclick="closeModal('editSuatChieuModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'update' and not empty errorMessage}">
            <div class="alert-error" id="editSuatChieuError" style="margin-bottom: 16px;"><c:out value="${errorMessage}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/suat-chieu/update" method="POST">
            <input type="hidden" id="editMaSuat" name="maSuat" value="${scUpdate != null ? scUpdate.maSuat : formSc.maSuat}">

            <div class="modal-form-grid">
                <div class="form-group">
                    <label>Mã suất chiếu</label>
                    <input type="text" id="editMaSuatCode" class="form-control" value="${scUpdate != null ? scUpdate.maSuatFormatted : formSc.maSuatFormatted}" readonly style="background: #f1f5f9; font-weight: 700; color: #0284c7;">
                </div>

                <div class="form-group">
                    <label>Trạng thái suất chiếu</label>
                    <select id="editTrangThai" name="trangThai" class="form-control">
                        <c:set var="curSt" value="${scUpdate != null ? scUpdate.trangThai : formSc.trangThai}" />
                        <option value="Đang mở bán" ${curSt == 'Đang mở bán' ? 'selected' : ''}>Đang mở bán</option>
                        <option value="Sắp diễn ra" ${curSt == 'Sắp diễn ra' ? 'selected' : ''}>Sắp diễn ra</option>
                        <option value="Đã đóng bán" ${curSt == 'Đã đóng bán' ? 'selected' : ''}>Đã đóng bán</option>
                        <option value="Đã hủy" ${curSt == 'Đã hủy' ? 'selected' : ''}>Đã hủy</option>
                    </select>
                </div>

                <div class="form-group full-col">
                    <label>Bộ Phim <span class="required-star">*</span></label>
                    <select id="editMaPhim" name="maPhim" class="form-control" required onchange="calculateEndTime('edit')">
                        <c:set var="curPhimId" value="${scUpdate != null ? scUpdate.phim.maPhim : (formSc != null ? formSc.phim.maPhim : rawMaPhim)}" />
                        <c:forEach items="${listPhimDangChieu}" var="p">
                            <option value="${p.maPhim}" data-duration="${p.thoiLuong}" ${p.maPhim == curPhimId ? 'selected' : ''}>
                                ${p.tenPhim} (${p.thoiLuong} phút)
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label>Phòng chiếu <span class="required-star">*</span></label>
                    <select id="editMaPhong" name="maPhong" class="form-control" required onchange="onPhongChange('edit')">
                        <c:set var="curPhongId" value="${scUpdate != null ? scUpdate.phongChieu.maPhong : (formSc != null ? formSc.phongChieu.maPhong : rawMaPhong)}" />
                        <c:forEach items="${listPhong}" var="pc">
                            <option value="${pc.maPhong}" data-loai="${pc.loaiPhong}" ${pc.maPhong == curPhongId ? 'selected' : ''}>
                                ${pc.tenPhong} (${pc.sucChua} ghế - ${pc.loaiPhong})
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label>Định dạng chiếu <span class="required-star">*</span></label>
                    <c:set var="curDinhDang" value="${scUpdate != null ? scUpdate.dinhDang : formSc.dinhDang}" />
                    <select id="editDinhDang" name="dinhDang" class="form-control">
                        <option value="2D" ${curDinhDang == '2D' ? 'selected' : ''}>2D</option>
                        <option value="3D" ${curDinhDang == '3D' ? 'selected' : ''}>3D</option>
                        <option value="IMAX" ${curDinhDang == 'IMAX' ? 'selected' : ''}>IMAX</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Ngày chiếu <span class="required-star">*</span></label>
                    <c:set var="curNgay" value="${scUpdate != null ? scUpdate.ngayChieu : (formSc != null ? formSc.ngayChieu : rawNgayChieu)}" />
                    <input type="date" id="editNgayChieu" name="ngayChieu" class="form-control" value="${curNgay}" required>
                </div>

                <div class="form-group">
                    <label>Thời gian dọn dẹp (phút)</label>
                    <input type="number" id="editThoiGianDonDep" name="thoiGianDonDep" class="form-control" value="15" min="0" max="60" onchange="calculateEndTime('edit')" placeholder="15">
                </div>

                <div class="form-group">
                    <label>Giờ bắt đầu (24h) <span class="required-star">*</span></label>
                    <c:set var="curGio" value="${scUpdate != null ? scUpdate.gioBatDau : (formSc != null ? formSc.gioBatDau : rawGioBatDau)}" />
                    <input type="time" id="editGioBatDau" name="gioBatDau" class="form-control" value="${curGio}" required onchange="calculateEndTime('edit')">
                    <div class="quick-time-group">
                        <span class="btn-time-chip" onclick="setTime('edit', '09:00')">09:00</span>
                        <span class="btn-time-chip" onclick="setTime('edit', '12:00')">12:00</span>
                        <span class="btn-time-chip" onclick="setTime('edit', '14:30')">14:30</span>
                        <span class="btn-time-chip" onclick="setTime('edit', '18:00')">18:00</span>
                        <span class="btn-time-chip" onclick="setTime('edit', '20:30')">20:30</span>
                        <span class="btn-time-chip" onclick="setTime('edit', '22:15')">22:15</span>
                    </div>
                </div>

                <div class="form-group">
                    <label>Giờ kết thúc</label>
                    <input type="text" id="editGioKetThucDisplay" class="form-control" value="${scUpdate != null ? scUpdate.gioKetThuc : 'Tự động tính'}" readonly style="background: #f1f5f9; color: #475569; font-weight: 600;">
                </div>

                <div class="form-group">
                    <label>Giá vé cơ bản (VNĐ) <span class="required-star">*</span></label>
                    <c:set var="curGia" value="${scUpdate != null ? scUpdate.giaVeCoBan : (formSc != null ? formSc.giaVeCoBan : 80000)}" />
                    <input type="number" id="editGiaVeCoBan" name="giaVeCoBan" class="form-control" value="${curGia}" step="5000" min="40000" required>
                </div>
            </div>

            <div class="modal-footer" style="margin-top: 20px;">
                <button type="button" class="btn btn-ghost" onclick="closeModal('editSuatChieuModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Lưu cập nhật</button>
            </div>
        </form>
    </div>
</div>

<!-- ================= MODAL 3: CHI TIẾT SUẤT CHIẾU ================= -->
<div class="modal-backdrop ${openModal == 'detail' ? 'open' : ''}" id="detailSuatChieuModal">
    <div class="modal-box" style="max-width: 520px;">
        <div class="modal-header">
            <h3>Chi Tiết Suất Chiếu</h3>
            <button type="button" class="modal-close" onclick="closeModal('detailSuatChieuModal')">&times;</button>
        </div>

        <div class="form-stack">
            <div style="display: flex; gap: 14px; margin-bottom: 12px; align-items: center;">
                <div style="font-size: 26px;">🎬</div>
                <div>
                    <h4 id="detailPhim" style="margin: 0; font-size: 16px; color: var(--text-primary);"><c:out value="${scDetail.phim.tenPhim}"/></h4>
                    <span id="detailMaSuat" style="font-size: 12px; font-weight: 700; color: #0284c7;">${scDetail.maSuatFormatted}</span>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; font-size: 13px; background: #f8fafc; padding: 14px; border-radius: 10px; border: 1px solid var(--border-subtle);">
                <div><strong>Phòng chiếu:</strong> <span id="detailPhong"><c:out value="${scDetail.phongChieu.tenPhong}"/></span></div>
                <div><strong>Định dạng:</strong> <span id="detailDinhDang">${scDetail.dinhDang}</span></div>
                <div><strong>Ngày chiếu:</strong> <span id="detailNgay">${scDetail.ngayChieu}</span></div>
                <div><strong>Khung giờ:</strong> <span id="detailGio">${scDetail.gioBatDau} - ${scDetail.gioKetThuc}</span></div>
                <div><strong>Thời lượng:</strong> <span id="detailThoiLuong">${scDetail.phim.thoiLuong} phút</span></div>
                <div><strong>Giá vé cơ bản:</strong> <span id="detailGia" style="color: #059669; font-weight: 700;">${scDetail.giaVeCoBan} đ</span></div>
                <div style="grid-column: 1 / -1;">
                    <strong>Trạng thái:</strong> <span id="detailTrangThai" style="font-weight: 700;">${scDetail.trangThai}</span>
                </div>
                <div id="detailLyDoWrap" style="grid-column: 1 / -1; display: ${empty scDetail.lyDoHuy ? 'none' : 'block'};">
                    <strong style="color: var(--danger-red);">Lý do hủy:</strong> <span id="detailLyDo"><c:out value="${scDetail.lyDoHuy}"/></span>
                </div>
            </div>
        </div>

        <div class="modal-footer" style="margin-top: 20px;">
            <button type="button" class="btn btn-pink" onclick="closeModal('detailSuatChieuModal')">Đóng</button>
        </div>
    </div>
</div>

<!-- ================= MODAL 4: HỦY SUẤT CHIẾU (KHÔNG XÓA) ================= -->
<div class="modal-backdrop" id="cancelSuatChieuModal">
    <div class="modal-box" style="max-width: 440px;">
        <div class="modal-header">
            <h3 style="color: var(--danger-red);">Xác nhận Hủy Suất Chiếu</h3>
            <button type="button" class="modal-close" onclick="closeModal('cancelSuatChieuModal')">&times;</button>
        </div>

        <form method="POST" action="${pageContext.request.contextPath}/suat-chieu/cancel">
            <input type="hidden" id="cancelMaSuat" name="id" value="">
            
            <p style="font-size: 13.5px; color: var(--text-secondary); margin-bottom: 14px;">
                Bạn có chắc chắn muốn hủy suất chiếu <strong id="cancelMaSuatTxt" style="color: #0284c7;"></strong> 
                của phim <strong id="cancelTenPhim"></strong> không?
            </p>
            <div style="font-size: 12px; color: #b91c1c; background: #fef2f2; border: 1px solid #fecaca; padding: 10px; border-radius: 8px; margin-bottom: 14px;">
                ⚠️ <strong>Lưu ý nghiệp vụ:</strong> Suất chiếu sẽ chuyển sang trạng thái <strong>"Đã hủy"</strong> để lưu trữ lịch sử báo cáo, không xóa vĩnh viễn khỏi Database!
            </div>

            <div style="margin-bottom: 18px;">
                <label style="display: block; font-size: 12px; font-weight: 700; margin-bottom: 6px;">Lý do hủy suất (*)</label>
                <input type="text" name="lyDo" class="form-control" placeholder="VD: Sự cố máy chiếu, đổi lịch, mất điện..." required>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('cancelSuatChieuModal')">Quay lại</button>
                <button type="submit" class="btn btn-pink" style="background: var(--danger-red); border-color: var(--danger-red);">Xác nhận Hủy</button>
            </div>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=15"></script>
<script>
    // Mở popup Thêm
    function openAddSuatChieu() {
        const err = document.getElementById('addSuatChieuError');
        if (err) err.style.display = 'none';
        document.getElementById('addGioKetThucDisplay').value = "Tự động tính (+15p dọn dẹp)";
        onPhongChange('add');
        openModal('addSuatChieuModal');
    }

    // Mở popup Sửa từ button trên bảng
    function openEditSuatChieuFromBtn(btn) {
        const err = document.getElementById('editSuatChieuError');
        if (err) err.style.display = 'none';

        const id = btn.getAttribute('data-id') || '';
        const code = btn.getAttribute('data-code') || '';
        const phim = btn.getAttribute('data-phim') || '';
        const phong = btn.getAttribute('data-phong') || '';
        let dinhdang = btn.getAttribute('data-dinhdang') || '2D';
        if (dinhdang.toUpperCase().includes('IMAX')) {
            dinhdang = 'IMAX';
        } else if (dinhdang.toUpperCase().includes('3D')) {
            dinhdang = '3D';
        } else {
            dinhdang = '2D';
        }
        const ngay = btn.getAttribute('data-ngay') || '';
        let gio = btn.getAttribute('data-gio') || '';
        if (gio && gio.length > 5) gio = gio.substring(0, 5);
        const gia = btn.getAttribute('data-gia') || '80000';
        const trangthai = btn.getAttribute('data-trangthai') || 'Đang mở bán';

        document.getElementById('editMaSuat').value = id;
        document.getElementById('editMaSuatCode').value = code ? code : ('SC' + String(id).padStart(3, '0'));
        document.getElementById('editMaPhim').value = phim;
        document.getElementById('editMaPhong').value = phong;
        document.getElementById('editDinhDang').value = dinhdang;
        document.getElementById('editNgayChieu').value = ngay;
        document.getElementById('editGioBatDau').value = gio;
        document.getElementById('editGiaVeCoBan').value = gia;
        document.getElementById('editTrangThai').value = trangthai;

        calculateEndTime('edit');
        openModal('editSuatChieuModal');
    }

    // Mở popup Chi tiết từ button trên bảng
    function openDetailSuatChieuFromBtn(btn) {
        document.getElementById('detailMaSuat').textContent = btn.getAttribute('data-code') || '';
        document.getElementById('detailPhim').textContent = btn.getAttribute('data-phim') || '';
        document.getElementById('detailPhong').textContent = btn.getAttribute('data-phong') || '';
        document.getElementById('detailDinhDang').textContent = btn.getAttribute('data-dinhdang') || '';
        document.getElementById('detailNgay').textContent = btn.getAttribute('data-ngay') || '';
        document.getElementById('detailGio').textContent = btn.getAttribute('data-gio') || '';
        document.getElementById('detailThoiLuong').textContent = btn.getAttribute('data-thoiluong') || '';
        document.getElementById('detailGia').textContent = btn.getAttribute('data-gia') || '';
        document.getElementById('detailTrangThai').textContent = btn.getAttribute('data-trangthai') || '';

        const lydo = btn.getAttribute('data-lydo') || '';
        const lydoWrap = document.getElementById('detailLyDoWrap');
        if (lydo && lydo.trim() !== '') {
            document.getElementById('detailLyDo').textContent = lydo;
            lydoWrap.style.display = 'block';
        } else {
            lydoWrap.style.display = 'none';
        }

        openModal('detailSuatChieuModal');
    }

    // Mở popup Hủy từ button trên bảng
    function openCancelModalFromBtn(btn) {
        document.getElementById('cancelMaSuat').value = btn.getAttribute('data-id') || '';
        document.getElementById('cancelMaSuatTxt').textContent = btn.getAttribute('data-code') || '';
        document.getElementById('cancelTenPhim').textContent = btn.getAttribute('data-tenphim') || '';
        openModal('cancelSuatChieuModal');
    }

    // Chọn nhanh giờ
    function setTime(prefix, timeVal) {
        const input = document.getElementById(prefix === 'edit' ? 'editGioBatDau' : 'addGioBatDau');
        if (input) {
            input.value = timeVal;
            calculateEndTime(prefix);
        }
    }

    // Tự động chọn định dạng chiếu khi chọn phòng (Phòng 2D ra 2D, 3D ra 3D, IMAX ra IMAX)
    function onPhongChange(prefix) {
        const phongSelect = document.getElementById(prefix === 'edit' ? 'editMaPhong' : 'addMaPhong');
        const dinhDangSelect = document.getElementById(prefix === 'edit' ? 'editDinhDang' : 'addDinhDang');
        if (!phongSelect || !dinhDangSelect) return;

        const opt = phongSelect.options[phongSelect.selectedIndex];
        if (!opt || !opt.value) return;

        const loaiPhong = (opt.getAttribute('data-loai') || opt.text || '').toUpperCase();
        if (loaiPhong.includes('IMAX')) {
            dinhDangSelect.value = 'IMAX';
        } else if (loaiPhong.includes('3D')) {
            dinhDangSelect.value = '3D';
        } else {
            dinhDangSelect.value = '2D';
        }
    }

    // Tự tính giờ kết thúc dựa trên thời lượng phim + thời gian dọn dẹp do người dùng nhập
    function calculateEndTime(prefix) {
        const isEdit = prefix === 'edit';
        const phimSelect = document.getElementById(isEdit ? 'editMaPhim' : 'addMaPhim');
        const startInput = document.getElementById(isEdit ? 'editGioBatDau' : 'addGioBatDau');
        const donDepInput = document.getElementById(isEdit ? 'editThoiGianDonDep' : 'addThoiGianDonDep');
        const display = document.getElementById(isEdit ? 'editGioKetThucDisplay' : 'addGioKetThucDisplay');

        if (!phimSelect || !startInput || !display) return;

        const opt = phimSelect.options[phimSelect.selectedIndex];
        const duration = opt ? parseInt(opt.getAttribute('data-duration') || 0) : 0;
        const startTime = startInput.value;
        const donDep = donDepInput ? (parseInt(donDepInput.value) || 0) : 15;

        if (!startTime || !duration) {
            display.value = "Tự động tính (+" + donDep + "p dọn dẹp)";
            return;
        }

        const [h, m] = startTime.split(':').map(Number);
        const totalMinutes = h * 60 + m + duration + donDep;
        const endH = Math.floor(totalMinutes / 60) % 24;
        const endM = totalMinutes % 60;

        const formattedEnd = String(endH).padStart(2, '0') + ':' + String(endM).padStart(2, '0');
        display.value = formattedEnd + " (Đã gồm " + donDep + "p dọn dẹp)";
    }

    // Phân trang
    function changePage(pageNum) {
        if (!pageNum || pageNum < 1) pageNum = 1;
        const pageInput = document.getElementById('pageNumberInput');
        const filterForm = document.getElementById('filterForm');
        if (pageInput && filterForm) {
            pageInput.value = pageNum;
            filterForm.submit();
        }
    }

    function changePageSize(size) {
        const pageSizeInput = document.getElementById('pageSizeInput');
        const pageInput = document.getElementById('pageNumberInput');
        const filterForm = document.getElementById('filterForm');
        if (pageSizeInput && pageInput && filterForm) {
            pageSizeInput.value = size;
            pageInput.value = 1;
            filterForm.submit();
        }
    }

    // Chuyển đổi giữa chế độ Danh sách và Lịch phòng chiếu
    function switchViewMode(mode) {
        const btnList = document.getElementById('btnTabList');
        const btnTimeline = document.getElementById('btnTabTimeline');
        const viewList = document.getElementById('viewListContainer');
        const viewTimeline = document.getElementById('viewTimelineContainer');

        if (!btnList || !btnTimeline || !viewList || !viewTimeline) return;

        if (mode === 'timeline') {
            btnList.className = 'btn btn-outline btn-sm';
            btnList.style.background = '#fff';
            btnTimeline.className = 'btn btn-pink btn-sm';
            btnTimeline.style.background = '';
            viewList.style.display = 'none';
            viewTimeline.style.display = 'flex';
            localStorage.setItem('suatChieuViewMode', 'timeline');
        } else {
            btnList.className = 'btn btn-pink btn-sm';
            btnList.style.background = '';
            btnTimeline.className = 'btn btn-outline btn-sm';
            btnTimeline.style.background = '#fff';
            viewList.style.display = 'block';
            viewTimeline.style.display = 'none';
            localStorage.setItem('suatChieuViewMode', 'list');
        }
    }

    // Nhanh chóng thêm suất chiếu cho một phòng cụ thể từ màn hình Lịch phòng chiếu
    function openAddSuatChieuForRoom(maPhong, loaiPhong) {
        openAddSuatChieu();
        const selPhong = document.getElementById('addMaPhong');
        if (selPhong && maPhong) {
            selPhong.value = maPhong;
            onPhongChange('add');
        }
    }

    // Lọc nhanh theo Ngày, Tuần, Tháng
    function setDateFilter(type) {
        const today = new Date();
        function fmt(d) {
            const year = d.getFullYear();
            const month = String(d.getMonth() + 1).padStart(2, '0');
            const day = String(d.getDate()).padStart(2, '0');
            return year + '-' + month + '-' + day;
        }

        let tuNgay = '';
        let denNgay = '';

        if (type === 'today') {
            tuNgay = fmt(today);
            denNgay = fmt(today);
        } else if (type === 'week') {
            const dayOfWeek = today.getDay(); // 0: CN, 1: T2, ...
            const diffToMon = (dayOfWeek === 0 ? -6 : 1) - dayOfWeek;
            const mon = new Date(today);
            mon.setDate(today.getDate() + diffToMon);
            const sun = new Date(mon);
            sun.setDate(mon.getDate() + 6);
            tuNgay = fmt(mon);
            denNgay = fmt(sun);
        } else if (type === 'month') {
            const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
            const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0);
            tuNgay = fmt(firstDay);
            denNgay = fmt(lastDay);
        }

        const inpTu = document.getElementById('filterTuNgay');
        const inpDen = document.getElementById('filterDenNgay');
        if (inpTu) inpTu.value = tuNgay;
        if (inpDen) inpDen.value = denNgay;

        const pageInput = document.getElementById('pageNumberInput');
        if (pageInput) pageInput.value = 1;

        const filterForm = document.getElementById('filterForm');
        if (filterForm) filterForm.submit();
    }

    // Tự động tô màu nút Ngày/Tuần/Tháng đang kích hoạt
    function highlightDateRangeBtn() {
        const inpTu = document.getElementById('filterTuNgay');
        const inpDen = document.getElementById('filterDenNgay');
        if (!inpTu || !inpDen) return;

        const tu = inpTu.value;
        const den = inpDen.value;
        if (!tu || !den) return;

        const today = new Date();
        function fmt(d) {
            return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
        }
        const todayStr = fmt(today);

        // Tính ngày đầu và cuối tuần
        const dayOfWeek = today.getDay();
        const diffToMon = (dayOfWeek === 0 ? -6 : 1) - dayOfWeek;
        const mon = new Date(today);
        mon.setDate(today.getDate() + diffToMon);
        const sun = new Date(mon);
        sun.setDate(mon.getDate() + 6);
        const monStr = fmt(mon);
        const sunStr = fmt(sun);

        // Tính ngày đầu và cuối tháng
        const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
        const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0);
        const firstStr = fmt(firstDay);
        const lastStr = fmt(lastDay);

        let activeId = null;
        if (tu === todayStr && den === todayStr) {
            activeId = 'btnDateToday';
        } else if (tu === monStr && den === sunStr) {
            activeId = 'btnDateWeek';
        } else if (tu === firstStr && den === lastStr) {
            activeId = 'btnDateMonth';
        }

        if (activeId) {
            ['btnDateToday', 'btnDateWeek', 'btnDateMonth'].forEach(id => {
                const b = document.getElementById(id);
                if (b) {
                    if (id === activeId) {
                        b.style.background = 'var(--pink)';
                        b.style.color = '#fff';
                        b.style.fontWeight = '700';
                    } else {
                        b.style.background = 'transparent';
                        b.style.color = 'var(--text-secondary)';
                        b.style.fontWeight = '600';
                    }
                }
            });
        }
    }

    // Tự động tính toán khi trang load nếu đang mở modal
    window.addEventListener('DOMContentLoaded', () => {
        onPhongChange('add');
        calculateEndTime('add');
        calculateEndTime('edit');
        highlightDateRangeBtn();
        const savedMode = localStorage.getItem('suatChieuViewMode');
        if (savedMode === 'timeline') {
            switchViewMode('timeline');
        }
    });
</script>
</body>
</html>
