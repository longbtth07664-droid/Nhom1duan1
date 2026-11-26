-- ==============================================================================
-- SCRIPT BỔ SUNG DATABASE DỰ ÁN CINEMAX (KHÔNG LÀM MẤT DỮ LIỆU CŨ)
-- Chạy trên SQL Server Management Studio (SSMS)
-- ==============================================================================

-- 1. TẠO BẢNG KhuyenMai (NẾU CHƯA CÓ)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'KhuyenMai')
BEGIN
    CREATE TABLE KhuyenMai (
        MaKM INT IDENTITY(1,1) PRIMARY KEY,
        TenKM NVARCHAR(100) NOT NULL,
        MaCode VARCHAR(50) NOT NULL UNIQUE,
        PhanTramGiam DECIMAL(5,2) NOT NULL DEFAULT 0,
        SoTienGiamToiDa DECIMAL(18,2) NOT NULL DEFAULT 0,
        DonToiThieu DECIMAL(18,2) NOT NULL DEFAULT 0,
        NgayBatDau DATETIME NOT NULL,
        NgayKetThuc DATETIME NOT NULL,
        TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đang áp dụng'
    );
    PRINT N'Đã tạo bảng KhuyenMai thành công!';
END
GO

-- 2. TẠO BẢNG DinhDang (Định dạng trình chiếu: 2D, 3D, IMAX 2D, IMAX 3D, 4DX...)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DinhDang')
BEGIN
    CREATE TABLE DinhDang (
        MaDinhDang INT IDENTITY(1,1) PRIMARY KEY,
        TenDinhDang NVARCHAR(50) NOT NULL UNIQUE,
        PhuThu DECIMAL(18,2) NOT NULL DEFAULT 0
    );
    PRINT N'Đã tạo bảng DinhDang thành công!';
END
GO

-- 3. TẠO BẢNG Phong_DinhDang (Phòng chiếu hỗ trợ các định dạng nào)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Phong_DinhDang')
BEGIN
    CREATE TABLE Phong_DinhDang (
        MaPhong INT NOT NULL,
        MaDinhDang INT NOT NULL,
        CONSTRAINT PK_Phong_DinhDang PRIMARY KEY (MaPhong, MaDinhDang),
        CONSTRAINT FK_PDD_Phong FOREIGN KEY (MaPhong) REFERENCES PhongChieu(MaPhong) ON DELETE CASCADE,
        CONSTRAINT FK_PDD_DinhDang FOREIGN KEY (MaDinhDang) REFERENCES DinhDang(MaDinhDang) ON DELETE CASCADE
    );
    PRINT N'Đã tạo bảng Phong_DinhDang thành công!';
END
GO

-- 4. TẠO BẢNG Phim_DinhDang (Phim phát hành có các định dạng nào)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Phim_DinhDang')
BEGIN
    CREATE TABLE Phim_DinhDang (
        MaPhim INT NOT NULL,
        MaDinhDang INT NOT NULL,
        CONSTRAINT PK_Phim_DinhDang PRIMARY KEY (MaPhim, MaDinhDang),
        CONSTRAINT FK_PhimDD_Phim FOREIGN KEY (MaPhim) REFERENCES Phim(MaPhim) ON DELETE CASCADE,
        CONSTRAINT FK_PhimDD_DinhDang FOREIGN KEY (MaDinhDang) REFERENCES DinhDang(MaDinhDang) ON DELETE CASCADE
    );
    PRINT N'Đã tạo bảng Phim_DinhDang thành công!';
END
GO

-- 5. CẬP NHẬT BẢNG SuatChieu (THÊM CỘT MaDinhDang VÀ KHÓA NGOẠI)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SuatChieu') AND name = 'MaDinhDang')
BEGIN
    ALTER TABLE SuatChieu ADD MaDinhDang INT NULL;
    PRINT N'Đã thêm cột MaDinhDang vào bảng SuatChieu!';
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Suat_DinhDang')
BEGIN
    ALTER TABLE SuatChieu
    ADD CONSTRAINT FK_Suat_DinhDang FOREIGN KEY (MaDinhDang) REFERENCES DinhDang(MaDinhDang);
    PRINT N'Đã thêm khóa ngoại FK_Suat_DinhDang!';
END
GO

-- 6. BỔ SUNG KHÓA NGOẠI GIỮA HoaDon VÀ KhuyenMai
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_HD_KhuyenMai')
BEGIN
    ALTER TABLE HoaDon
    ADD CONSTRAINT FK_HD_KhuyenMai FOREIGN KEY (MaKM) REFERENCES KhuyenMai(MaKM);
    PRINT N'Đã thêm khóa ngoại FK_HD_KhuyenMai!';
END
GO

-- 7. BỔ SUNG CỘT SoTien VÀO BẢNG ThanhToan
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ThanhToan') AND name = 'SoTien')
BEGIN
    ALTER TABLE ThanhToan ADD SoTien DECIMAL(18,2) NOT NULL DEFAULT 0;
    PRINT N'Đã thêm cột SoTien vào bảng ThanhToan!';
END
GO

-- 8. BỔ SUNG CỘT NgaySinh VÀO BẢNG KhachHang
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('KhachHang') AND name = 'NgaySinh')
BEGIN
    ALTER TABLE KhachHang ADD NgaySinh DATE NULL;
    PRINT N'Đã thêm cột NgaySinh vào bảng KhachHang!';
END
GO

-- 9. CHUẨN HÓA KHÓA NGOẠI BẢNG PhongChieu VỚI LoaiPhong
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('PhongChieu') AND name = 'MaLoaiPhong')
BEGIN
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('PhongChieu') AND name = 'LoaiPhong')
    BEGIN
        EXEC sp_rename 'PhongChieu.LoaiPhong', 'MaLoaiPhong', 'COLUMN';
    END
    ELSE
    BEGIN
        ALTER TABLE PhongChieu ADD MaLoaiPhong VARCHAR(50) NULL;
    END
    PRINT N'Đã chuẩn hóa cột MaLoaiPhong trong PhongChieu!';
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Phong_LoaiPhong')
BEGIN
    ALTER TABLE PhongChieu
    ADD CONSTRAINT FK_Phong_LoaiPhong FOREIGN KEY (MaLoaiPhong) REFERENCES LoaiPhong(MaLoaiPhong);
    PRINT N'Đã tạo khóa ngoại FK_Phong_LoaiPhong!';
END
GO

-- ==============================================================================
-- DỮ LIỆU MẪU BAN ĐẦU (SEED DATA)
-- ==============================================================================
-- Thêm dữ liệu mẫu định dạng chiếu
IF NOT EXISTS (SELECT * FROM DinhDang WHERE TenDinhDang = N'2D')
    INSERT INTO DinhDang (TenDinhDang, PhuThu) VALUES (N'2D', 0);
IF NOT EXISTS (SELECT * FROM DinhDang WHERE TenDinhDang = N'3D')
    INSERT INTO DinhDang (TenDinhDang, PhuThu) VALUES (N'3D', 30000);
IF NOT EXISTS (SELECT * FROM DinhDang WHERE TenDinhDang = N'IMAX 2D')
    INSERT INTO DinhDang (TenDinhDang, PhuThu) VALUES (N'IMAX 2D', 50000);
IF NOT EXISTS (SELECT * FROM DinhDang WHERE TenDinhDang = N'IMAX 3D')
    INSERT INTO DinhDang (TenDinhDang, PhuThu) VALUES (N'IMAX 3D', 80000);
IF NOT EXISTS (SELECT * FROM DinhDang WHERE TenDinhDang = N'4DX 2D')
    INSERT INTO DinhDang (TenDinhDang, PhuThu) VALUES (N'4DX 2D', 60000);
IF NOT EXISTS (SELECT * FROM DinhDang WHERE TenDinhDang = N'4DX 3D')
    INSERT INTO DinhDang (TenDinhDang, PhuThu) VALUES (N'4DX 3D', 90000);

-- Cập nhật dữ liệu mặc định cho SuatChieu nếu MaDinhDang đang NULL
UPDATE SuatChieu 
SET MaDinhDang = (SELECT TOP 1 MaDinhDang FROM DinhDang WHERE TenDinhDang = N'2D')
WHERE MaDinhDang IS NULL;

-- Thêm voucher khuyến mãi mẫu
IF NOT EXISTS (SELECT * FROM KhuyenMai WHERE MaCode = 'CHAOMUNG')
    INSERT INTO KhuyenMai (TenKM, MaCode, PhanTramGiam, SoTienGiamToiDa, DonToiThieu, NgayBatDau, NgayKetThuc, TrangThai)
    VALUES (N'Chào Mừng Thành Viên Mới', 'CHAOMUNG', 10.00, 50000, 100000, '2026-01-01', '2026-12-31', N'Đang áp dụng');
GO
