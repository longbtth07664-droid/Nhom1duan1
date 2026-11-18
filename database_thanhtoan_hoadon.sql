-- ============================================================================
-- DỰ ÁN 1: QUẢN LÝ ĐẶT VÉ RẠP CHIẾU PHIM CINEMAX
-- TÀI LIỆU CƠ SỞ DỮ LIỆU THAM CHIẾU: MODULE THANH TOÁN & HÓA ĐƠN
-- Dành cho đợt bổ sung/cập nhật CSDL của nhóm
-- ============================================================================

USE QuanLyDatVeRapPhim;
GO

-- 1. BẢNG HOÁ ĐƠN (HoaDon)
-- Lưu thông tin tổng quát của đơn đặt vé / giao dịch tại quầy
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'HoaDon')
BEGIN
    CREATE TABLE HoaDon (
        MaDatVe INT IDENTITY(1,1) PRIMARY KEY,
        MaTK INT NOT NULL,                          -- Nhân viên/Thu ngân lập đơn
        MaKH NVARCHAR(20) NULL,                     -- Khách hàng thành viên (nếu có)
        MaKM INT NULL,                              -- Mã khuyến mãi / voucher (nếu có)
        NgayDat DATETIME DEFAULT GETDATE(),         -- Thời gian lập hóa đơn
        TongTien DECIMAL(18,2) NOT NULL DEFAULT 0,  -- Tổng số tiền thanh toán thực tế
        TienGiam DECIMAL(18,2) DEFAULT 0,           -- Số tiền giảm giá (từ điểm tích lũy hoặc KM)
        TrangThai NVARCHAR(50) DEFAULT N'Đã hoàn tất'-- Trạng thái: 'Đã hoàn tất', 'Đã hủy', 'Chờ xử lý'
    );
END
ELSE
BEGIN
    -- Kiểm tra và bổ sung các cột nếu CSDL cũ còn thiếu
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('HoaDon') AND name = 'MaKH')
        ALTER TABLE HoaDon ADD MaKH NVARCHAR(20) NULL;

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('HoaDon') AND name = 'TienGiam')
        ALTER TABLE HoaDon ADD TienGiam DECIMAL(18,2) DEFAULT 0;
END
GO

-- 2. BẢNG VÉ XEM PHIM (Ve)
-- Lưu chi tiết từng ghế ngồi được bán trong suất chiếu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Ve')
BEGIN
    CREATE TABLE Ve (
        MaVe INT IDENTITY(1,1) PRIMARY KEY,
        MaDatVe INT NOT NULL,                       -- Khóa ngoại liên kết tới HoaDon(MaDatVe)
        MaSuat INT NOT NULL,                        -- Suất chiếu phim
        MaGhe INT NOT NULL,                         -- Ghế ngồi trong phòng chiếu
        GiaVe DECIMAL(18,2) NOT NULL DEFAULT 0,     -- Giá bán thực tế của vé
        MaQR VARCHAR(100) NULL,                     -- Mã Barcode / QR quét tại cổng soát vé
        TrangThai NVARCHAR(30) DEFAULT N'Đã bán'    -- Trạng thái vé: 'Đã bán', 'Đã in', 'Đã hủy'
    );
END
GO

-- 3. BẢNG CHI TIẾT HÓA ĐƠN COMBO / BẮP NƯỚC (ChiTietHoaDon)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChiTietHoaDon')
BEGIN
    CREATE TABLE ChiTietHoaDon (
        MaChiTiet INT IDENTITY(1,1) PRIMARY KEY,
        MaDatVe INT NOT NULL,                       -- Khóa ngoại liên kết tới HoaDon(MaDatVe)
        MaSP INT NULL,                              -- Mã sản phẩm lẻ (nếu bán lẻ)
        MaCombo INT NULL,                           -- Mã gói combo bắp nước
        SoLuong INT NOT NULL DEFAULT 1,             -- Số lượng combo/sản phẩm
        DonGia DECIMAL(18,2) NOT NULL DEFAULT 0     -- Đơn giá tại thời điểm bán
    );
END
GO

-- 4. BẢNG GIAO DỊCH THANH TOÁN (ThanhToan)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ThanhToan')
BEGIN
    CREATE TABLE ThanhToan (
        MaThanhToan INT IDENTITY(1,1) PRIMARY KEY,
        MaDatVe INT NOT NULL,                       -- Khóa ngoại liên kết tới HoaDon(MaDatVe)
        PhuongThuc NVARCHAR(50) NOT NULL,           -- 'Tiền mặt', 'Chuyển khoản (VietQR)', 'Thẻ ngân hàng'
        NgayThanhToan DATETIME DEFAULT GETDATE(),   -- Thời gian hoàn tất giao dịch
        TrangThai NVARCHAR(50) DEFAULT N'Thành công'-- 'Thành công', 'Thất bại', 'Đang xử lý'
    );
END
GO
