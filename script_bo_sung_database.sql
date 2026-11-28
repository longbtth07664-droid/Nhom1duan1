-- ==============================================================================
-- SCRIPT BỔ SUNG DATABASE DỰ ÁN CINEMAX (KHÔNG LÀM MẤT DỮ LIỆU CŨ)
-- ĐÃ NÂNG CẤP MÃ GIẢM GIÁ THEO GIỜ CHIẾU, THỨ TRONG TUẦN VÀ ĐỘ TUỔI
-- ==============================================================================
USE QuanLyDatVeRapPhim;
GO

-- 1. BỔ SUNG HOẶC CẬP NHẬT BẢNG KhuyenMai
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'KhuyenMai')
BEGIN
    CREATE TABLE KhuyenMai (
        MaKM INT IDENTITY(1,1) PRIMARY KEY,
        TenKM NVARCHAR(100) NOT NULL,
        MaCode VARCHAR(50) NOT NULL UNIQUE,
        PhanTramGiam DECIMAL(5,2) NOT NULL DEFAULT 0,
        SoTienGiamToiDa DECIMAL(18,2) NOT NULL DEFAULT 0,
        DonToiThieu DECIMAL(18,2) NOT NULL DEFAULT 0,
        GioChieuTu TIME NULL,
        GioChieuDen TIME NULL,
        ThuTrongTuan VARCHAR(50) NULL DEFAULT 'ALL',
        TuoiToiThieu INT NULL,
        TuoiToiDa INT NULL,
        SoVeToiThieu INT NOT NULL DEFAULT 1,
        MaDinhDangApDung INT NULL,
        NgayBatDau DATETIME NOT NULL,
        NgayKetThuc DATETIME NOT NULL,
        TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đang áp dụng'
    );
    PRINT N'==> Đã tạo bảng KhuyenMai nâng cao thành công!';
END
ELSE
BEGIN
    -- Nếu bảng KhuyenMai đã có, bổ sung các cột điều kiện nâng cao nếu chưa có
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('KhuyenMai') AND name = 'GioChieuTu')
        ALTER TABLE KhuyenMai ADD GioChieuTu TIME NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('KhuyenMai') AND name = 'GioChieuDen')
        ALTER TABLE KhuyenMai ADD GioChieuDen TIME NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('KhuyenMai') AND name = 'ThuTrongTuan')
        ALTER TABLE KhuyenMai ADD ThuTrongTuan VARCHAR(50) NULL DEFAULT 'ALL';
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('KhuyenMai') AND name = 'TuoiToiThieu')
        ALTER TABLE KhuyenMai ADD TuoiToiThieu INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('KhuyenMai') AND name = 'TuoiToiDa')
        ALTER TABLE KhuyenMai ADD TuoiToiDa INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('KhuyenMai') AND name = 'SoVeToiThieu')
        ALTER TABLE KhuyenMai ADD SoVeToiThieu INT NOT NULL DEFAULT 1;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('KhuyenMai') AND name = 'MaDinhDangApDung')
        ALTER TABLE KhuyenMai ADD MaDinhDangApDung INT NULL;
    PRINT N'==> Đã nâng cấp các cột điều kiện giờ chiếu và độ tuổi cho bảng KhuyenMai!';
END
GO

-- 2. TẠO KHÓA NGOẠI GIỮA HoaDon VÀ KhuyenMai
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_HD_KhuyenMai')
BEGIN
    ALTER TABLE HoaDon
    ADD CONSTRAINT FK_HD_KhuyenMai FOREIGN KEY (MaKM) REFERENCES KhuyenMai(MaKM);
    PRINT N'==> Đã thêm khóa ngoại FK_HD_KhuyenMai vào bảng HoaDon!';
END
GO

-- 3. BỔ SUNG CỘT NgaySinh VÀO BẢNG KhachHang (DÙNG ĐỂ TÍNH TUỔI)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('KhachHang') AND name = 'NgaySinh')
BEGIN
    ALTER TABLE KhachHang ADD NgaySinh DATE NULL;
    PRINT N'==> Đã thêm cột NgaySinh vào bảng KhachHang!';
END
GO

-- 4. BỔ SUNG CÁC MÃ KHUYẾN MÃI MẪU VỀ GIỜ CHIẾU VÀ ĐỘ TUỔI (SEED DATA)
-- Mã 1: U22_STUDENT (Học sinh - Sinh viên từ 12 đến 22 tuổi, giảm 20% tối đa 30.000đ)
IF NOT EXISTS (SELECT * FROM KhuyenMai WHERE MaCode = 'U22_STUDENT')
BEGIN
    INSERT INTO KhuyenMai (TenKM, MaCode, PhanTramGiam, SoTienGiamToiDa, DonToiThieu, TuoiToiThieu, TuoiToiDa, NgayBatDau, NgayKetThuc, TrangThai)
    VALUES (N'Ưu đãi HSSV & U22 (12-22 tuổi)', 'U22_STUDENT', 20.00, 30000, 50000, 12, 22, '2026-01-01', '2026-12-31', N'Đang áp dụng');
END

-- Mã 2: EARLY_BIRD (Suất chiếu sớm từ 08:00 đến 12:00, giảm 25% tối đa 40.000đ)
IF NOT EXISTS (SELECT * FROM KhuyenMai WHERE MaCode = 'EARLY_BIRD')
BEGIN
    INSERT INTO KhuyenMai (TenKM, MaCode, PhanTramGiam, SoTienGiamToiDa, DonToiThieu, GioChieuTu, GioChieuDen, NgayBatDau, NgayKetThuc, TrangThai)
    VALUES (N'Suất Chiếu Sớm (Trước 12h)', 'EARLY_BIRD', 25.00, 40000, 70000, '08:00:00', '12:00:00', '2026-01-01', '2026-12-31', N'Đang áp dụng');
END

-- Mã 3: MIDNIGHT (Suất chiếu khuya sau 22:00, giảm 20% tối đa 35.000đ)
IF NOT EXISTS (SELECT * FROM KhuyenMai WHERE MaCode = 'MIDNIGHT')
BEGIN
    INSERT INTO KhuyenMai (TenKM, MaCode, PhanTramGiam, SoTienGiamToiDa, DonToiThieu, GioChieuTu, GioChieuDen, NgayBatDau, NgayKetThuc, TrangThai)
    VALUES (N'Suất Chiếu Khuya (Sau 22h)', 'MIDNIGHT', 20.00, 35000, 60000, '22:00:00', '23:59:59', '2026-01-01', '2026-12-31', N'Đang áp dụng');
END

-- Mã 4: HAPPY_TUE (Thứ Ba vui vẻ, giảm 30% tối đa 50.000đ)
IF NOT EXISTS (SELECT * FROM KhuyenMai WHERE MaCode = 'HAPPY_TUE')
BEGIN
    INSERT INTO KhuyenMai (TenKM, MaCode, PhanTramGiam, SoTienGiamToiDa, DonToiThieu, ThuTrongTuan, NgayBatDau, NgayKetThuc, TrangThai)
    VALUES (N'Thứ Ba Vui Vẻ (Happy Tuesday)', 'HAPPY_TUE', 30.00, 50000, 80000, '3', '2026-01-01', '2026-12-31', N'Đang áp dụng');
END

-- Mã 5: SENIOR_60 (Người cao tuổi >= 60 tuổi, giảm 30% tối đa 50.000đ)
IF NOT EXISTS (SELECT * FROM KhuyenMai WHERE MaCode = 'SENIOR_60')
BEGIN
    INSERT INTO KhuyenMai (TenKM, MaCode, PhanTramGiam, SoTienGiamToiDa, DonToiThieu, TuoiToiThieu, NgayBatDau, NgayKetThuc, TrangThai)
    VALUES (N'Ưu đãi Người Cao Tuổi (>= 60 tuổi)', 'SENIOR_60', 30.00, 50000, 50000, 60, '2026-01-01', '2026-12-31', N'Đang áp dụng');
END
GO
PRINT N'==> Đã hoàn tất bổ sung toàn bộ hệ thống Khuyến mãi thông minh!';
GO
