-- ============================================================================
-- DỰ ÁN 1: HỆ THỐNG QUẢN LÝ VÀ ĐẶT VÉ RẠP CHIẾU PHIM CINEMAX
-- HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU: MICROSOFT SQL SERVER 2016+
-- TÊN DATABASE: QuanLyDatVeRapPhim
-- PHIÊN BẢN: HOÀN CHỈNH 100% (CHUẨN HÓA TOÀN BỘ 21 BẢNG THỰC THỂ)
-- Bao quát toàn bộ nghiệp vụ:
--   1. Phân quyền & Nhân sự (TaiKhoan / NhanVien)
--   2. Khách hàng thân thiết & Điểm tích lũy (KhachHang)
--   3. Phim & Thể loại (Phim, TheLoai, Phim_TheLoai)
--   4. Công nghệ trình chiếu & Loại phòng (DinhDang, LoaiPhong)
--   5. Phòng chiếu & Ghế ngồi (PhongChieu, Phong_DinhDang, LoaiGhe, Ghe)
--   6. Quan hệ Phim - Định dạng (Phim_DinhDang)
--   7. Lịch chiếu & Suất chiếu (SuatChieu)
--   8. Khuyến mãi & Voucher (KhuyenMai)
--   9. Quầy Bắp Nước & Gói Combo Ưu Đãi (SanPham, Combo, ChiTietCombo)
--  10. Bán vé POS, Hóa đơn, Vé điện tử & Thanh toán (HoaDon, Ve, ChiTietHoaDon, ThanhToan)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PHẦN 1: KHỞI TẠO CƠ SỞ DỮ LIỆU
-- ----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'QuanLyDatVeRapPhim')
BEGIN
    CREATE DATABASE QuanLyDatVeRapPhim;
    PRINT N'==> Đã khởi tạo mới Cơ sở dữ liệu: QuanLyDatVeRapPhim';
END
GO

USE QuanLyDatVeRapPhim;
GO

-- ----------------------------------------------------------------------------
-- PHẦN 2: DỌN DẸP BẢNG CŨ THEO THỨ TỰ RÀNG BUỘC (NẾU CẦN RESET TỪ ĐẦU)
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.ThanhToan', N'U') IS NOT NULL DROP TABLE dbo.ThanhToan;
IF OBJECT_ID(N'dbo.ChiTietHoaDon', N'U') IS NOT NULL DROP TABLE dbo.ChiTietHoaDon;
IF OBJECT_ID(N'dbo.Ve', N'U') IS NOT NULL DROP TABLE dbo.Ve;
IF OBJECT_ID(N'dbo.HoaDon', N'U') IS NOT NULL DROP TABLE dbo.HoaDon;
IF OBJECT_ID(N'dbo.KhuyenMai', N'U') IS NOT NULL DROP TABLE dbo.KhuyenMai;
IF OBJECT_ID(N'dbo.ChiTietCombo', N'U') IS NOT NULL DROP TABLE dbo.ChiTietCombo;
IF OBJECT_ID(N'dbo.Combo', N'U') IS NOT NULL DROP TABLE dbo.Combo;
IF OBJECT_ID(N'dbo.SanPham', N'U') IS NOT NULL DROP TABLE dbo.SanPham;
IF OBJECT_ID(N'dbo.SuatChieu', N'U') IS NOT NULL DROP TABLE dbo.SuatChieu;
IF OBJECT_ID(N'dbo.Phim_DinhDang', N'U') IS NOT NULL DROP TABLE dbo.Phim_DinhDang;
IF OBJECT_ID(N'dbo.Phong_DinhDang', N'U') IS NOT NULL DROP TABLE dbo.Phong_DinhDang;
IF OBJECT_ID(N'dbo.DinhDang', N'U') IS NOT NULL DROP TABLE dbo.DinhDang;
IF OBJECT_ID(N'dbo.Phim_TheLoai', N'U') IS NOT NULL DROP TABLE dbo.Phim_TheLoai;
IF OBJECT_ID(N'dbo.Phim', N'U') IS NOT NULL DROP TABLE dbo.Phim;
IF OBJECT_ID(N'dbo.TheLoai', N'U') IS NOT NULL DROP TABLE dbo.TheLoai;
IF OBJECT_ID(N'dbo.Ghe', N'U') IS NOT NULL DROP TABLE dbo.Ghe;
IF OBJECT_ID(N'dbo.LoaiGhe', N'U') IS NOT NULL DROP TABLE dbo.LoaiGhe;
IF OBJECT_ID(N'dbo.PhongChieu', N'U') IS NOT NULL DROP TABLE dbo.PhongChieu;
IF OBJECT_ID(N'dbo.LoaiPhong', N'U') IS NOT NULL DROP TABLE dbo.LoaiPhong;
IF OBJECT_ID(N'dbo.KhachHang', N'U') IS NOT NULL DROP TABLE dbo.KhachHang;
IF OBJECT_ID(N'dbo.TaiKhoan', N'U') IS NOT NULL DROP TABLE dbo.TaiKhoan;
GO

PRINT N'==> Đã dọn dẹp cấu trúc bảng cũ sẵn sàng tạo mới.';
GO

-- ----------------------------------------------------------------------------
-- PHẦN 3: ĐỊNH NGHĨA CẤU TRÚC 21 BẢNG DỮ LIỆU (DDL)
-- ----------------------------------------------------------------------------

-- 1. BẢNG TÀI KHOẢN (TaiKhoan)
CREATE TABLE TaiKhoan (
    MaTK INT IDENTITY(1,1) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    CCCD VARCHAR(20) NOT NULL UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    SoDienThoai VARCHAR(15) NOT NULL,
    DiaChi NVARCHAR(255) NULL,
    VaiTro NVARCHAR(20) NOT NULL DEFAULT N'NhanVien', -- 'QuanLy', 'NhanVien'
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Hoạt động'
);

-- 2. BẢNG KHÁCH HÀNG (KhachHang)
CREATE TABLE KhachHang (
    MaKH NVARCHAR(20) PRIMARY KEY,                    -- 'KH001', 'KH002'
    HoTen NVARCHAR(100) NOT NULL,
    SDT VARCHAR(15) NOT NULL UNIQUE,
    DiemTichLuy INT NOT NULL DEFAULT 0,
    GioiTinh NVARCHAR(10) NULL,                       -- 'Nam', 'Nữ', 'Khác'
    NgaySinh DATE NULL
);

-- 3. BẢNG THỂ LOẠI (TheLoai)
CREATE TABLE TheLoai (
    MaTheLoai INT IDENTITY(1,1) PRIMARY KEY,
    TenTheLoai NVARCHAR(100) NOT NULL UNIQUE
);

-- 4. BẢNG PHIM (Phim)
CREATE TABLE Phim (
    MaPhim INT IDENTITY(1,1) PRIMARY KEY,
    TenPhim NVARCHAR(255) NOT NULL,
    MoTa NVARCHAR(MAX) NULL,
    ThoiLuong INT NOT NULL,                           -- Phút
    NgayKhoiChieu DATE NOT NULL,
    NgayKetThuc DATE NOT NULL,
    DaoDien NVARCHAR(100) NULL,
    DienVien NVARCHAR(255) NULL,
    QuocGia NVARCHAR(50) NULL,
    Poster NVARCHAR(255) NULL,
    Trailer NVARCHAR(255) NULL,
    DoTuoi NVARCHAR(10) NULL,                         -- 'P', 'K', 'T13', 'T16', 'T18', 'C'
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đang chiếu'
);

-- 5. BẢNG TRUNG GIAN PHIM - THỂ LOẠI (Phim_TheLoai: N-N)
CREATE TABLE Phim_TheLoai (
    MaPhim INT NOT NULL,
    MaTheLoai INT NOT NULL,
    CONSTRAINT PK_Phim_TheLoai PRIMARY KEY (MaPhim, MaTheLoai),
    CONSTRAINT FK_PTL_Phim FOREIGN KEY (MaPhim) REFERENCES Phim(MaPhim) ON DELETE CASCADE,
    CONSTRAINT FK_PTL_TheLoai FOREIGN KEY (MaTheLoai) REFERENCES TheLoai(MaTheLoai) ON DELETE CASCADE
);

-- 6. BẢNG LOẠI PHÒNG (LoaiPhong)
CREATE TABLE LoaiPhong (
    MaLoaiPhong VARCHAR(50) PRIMARY KEY,              -- 'STANDARD', 'IMAX', '4DX', 'GOLD_CLASS'
    TenLoaiPhong NVARCHAR(100) NOT NULL
);

-- 7. BẢNG PHÒNG CHIẾU (PhongChieu)
CREATE TABLE PhongChieu (
    MaPhong INT IDENTITY(1,1) PRIMARY KEY,
    TenPhong NVARCHAR(100) NOT NULL,                  -- 'Phòng 01 - Tiêu Chuẩn'
    MaLoaiPhong VARCHAR(50) NULL,
    SucChua INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Phong_LoaiPhong FOREIGN KEY (MaLoaiPhong) REFERENCES LoaiPhong(MaLoaiPhong) ON DELETE SET NULL
);

-- 8. BẢNG ĐỊNH DẠNG TRÌNH CHIẾU (DinhDang)
CREATE TABLE DinhDang (
    MaDinhDang INT IDENTITY(1,1) PRIMARY KEY,
    TenDinhDang NVARCHAR(50) NOT NULL UNIQUE,         -- '2D', '3D', 'IMAX 2D', 'IMAX 3D', '4DX 2D'
    PhuThu DECIMAL(18,2) NOT NULL DEFAULT 0
);

-- 9. BẢNG PHÒNG - ĐỊNH DẠNG (Phong_DinhDang: N-N)
CREATE TABLE Phong_DinhDang (
    MaPhong INT NOT NULL,
    MaDinhDang INT NOT NULL,
    CONSTRAINT PK_Phong_DinhDang PRIMARY KEY (MaPhong, MaDinhDang),
    CONSTRAINT FK_PDD_Phong FOREIGN KEY (MaPhong) REFERENCES PhongChieu(MaPhong) ON DELETE CASCADE,
    CONSTRAINT FK_PDD_DinhDang FOREIGN KEY (MaDinhDang) REFERENCES DinhDang(MaDinhDang) ON DELETE CASCADE
);

-- 10. BẢNG PHIM - ĐỊNH DẠNG (Phim_DinhDang: N-N)
CREATE TABLE Phim_DinhDang (
    MaPhim INT NOT NULL,
    MaDinhDang INT NOT NULL,
    CONSTRAINT PK_Phim_DinhDang PRIMARY KEY (MaPhim, MaDinhDang),
    CONSTRAINT FK_PhimDD_Phim FOREIGN KEY (MaPhim) REFERENCES Phim(MaPhim) ON DELETE CASCADE,
    CONSTRAINT FK_PhimDD_DinhDang FOREIGN KEY (MaDinhDang) REFERENCES DinhDang(MaDinhDang) ON DELETE CASCADE
);

-- 11. BẢNG LOẠI GHẾ (LoaiGhe)
CREATE TABLE LoaiGhe (
    MaLoaiGhe INT IDENTITY(1,1) PRIMARY KEY,
    TenLoaiGhe NVARCHAR(50) NOT NULL UNIQUE,          -- 'Thường', 'VIP', 'Đôi (Sweetbox)'
    PhuThu DECIMAL(18,2) NOT NULL DEFAULT 0
);

-- 12. BẢNG GHẾ NGỒI (Ghe)
CREATE TABLE Ghe (
    MaGhe INT IDENTITY(1,1) PRIMARY KEY,
    MaPhong INT NOT NULL,
    MaLoaiGhe INT NOT NULL,
    HangGhe VARCHAR(5) NOT NULL,                      -- 'A', 'B', 'C'
    SoGhe INT NOT NULL,                               -- 1, 2, 3
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Hoạt động',
    CONSTRAINT UQ_Ghe_Phong UNIQUE (MaPhong, HangGhe, SoGhe),
    CONSTRAINT FK_Ghe_Phong FOREIGN KEY (MaPhong) REFERENCES PhongChieu(MaPhong) ON DELETE CASCADE,
    CONSTRAINT FK_Ghe_LoaiGhe FOREIGN KEY (MaLoaiGhe) REFERENCES LoaiGhe(MaLoaiGhe)
);

-- 13. BẢNG SUẤT CHIẾU (SuatChieu)
CREATE TABLE SuatChieu (
    MaSuat INT IDENTITY(1,1) PRIMARY KEY,
    MaPhim INT NOT NULL,
    MaPhong INT NOT NULL,
    MaDinhDang INT NOT NULL,
    NgayChieu DATE NOT NULL,
    GioBatDau TIME(0) NOT NULL,
    GioKetThuc TIME(0) NOT NULL,
    GiaVeCoBan DECIMAL(18,2) NOT NULL DEFAULT 80000,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đang mở bán',
    LyDoHuy NVARCHAR(255) NULL,
    CONSTRAINT FK_Suat_Phim FOREIGN KEY (MaPhim) REFERENCES Phim(MaPhim),
    CONSTRAINT FK_Suat_Phong FOREIGN KEY (MaPhong) REFERENCES PhongChieu(MaPhong),
    CONSTRAINT FK_Suat_DinhDang FOREIGN KEY (MaDinhDang) REFERENCES DinhDang(MaDinhDang)
);

-- 14. BẢNG KHUYẾN MÃI / VOUCHER (KhuyenMai)
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

-- 15. BẢNG SẢN PHẨM BẮP NƯỚC (SanPham)
CREATE TABLE SanPham (
    MaSP INT IDENTITY(1,1) PRIMARY KEY,
    TenSP NVARCHAR(100) NOT NULL,
    LoaiSP NVARCHAR(50) NOT NULL,                     -- 'Bắp rang', 'Nước ngọt', 'Snack'
    DonViTinh NVARCHAR(20) NOT NULL DEFAULT N'Phần',  -- 'Hộp', 'Ly', 'Gói'
    GiaBan DECIMAL(18,2) NOT NULL DEFAULT 0,
    SoLuongTon INT NOT NULL DEFAULT 0,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đang bán',
    HinhAnh NVARCHAR(255) NULL
);

-- 16. BẢNG GÓI COMBO ƯU ĐÃI (Combo)
CREATE TABLE Combo (
    MaCombo INT IDENTITY(1,1) PRIMARY KEY,
    TenCombo NVARCHAR(100) NOT NULL,
    GiaCombo DECIMAL(18,2) NOT NULL DEFAULT 0,
    MoTa NVARCHAR(255) NULL,
    HinhAnh NVARCHAR(255) NULL,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đang bán'
);

-- 17. BẢNG CHI TIẾT COMBO (ChiTietCombo: N-N giữa Combo và SanPham)
CREATE TABLE ChiTietCombo (
    MaCombo INT NOT NULL,
    MaSP INT NOT NULL,
    SoLuong INT NOT NULL DEFAULT 1,
    GhiChu NVARCHAR(100) NULL,
    CONSTRAINT PK_ChiTietCombo PRIMARY KEY (MaCombo, MaSP),
    CONSTRAINT FK_CTC_Combo FOREIGN KEY (MaCombo) REFERENCES Combo(MaCombo) ON DELETE CASCADE,
    CONSTRAINT FK_CTC_SanPham FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);

-- 18. BẢNG HÓA ĐƠN ĐẶT VÉ (HoaDon)
CREATE TABLE HoaDon (
    MaDatVe INT IDENTITY(1,1) PRIMARY KEY,
    MaTK INT NOT NULL,
    MaKH NVARCHAR(20) NULL,
    MaKM INT NULL,
    NgayDat DATETIME NOT NULL DEFAULT GETDATE(),
    TongTien DECIMAL(18,2) NOT NULL DEFAULT 0,
    TienGiam DECIMAL(18,2) NOT NULL DEFAULT 0,
    TrangThai NVARCHAR(50) NOT NULL DEFAULT N'Đã hoàn tất',
    CONSTRAINT FK_HD_TaiKhoan FOREIGN KEY (MaTK) REFERENCES TaiKhoan(MaTK),
    CONSTRAINT FK_HD_KhachHang FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH) ON DELETE SET NULL,
    CONSTRAINT FK_HD_KhuyenMai FOREIGN KEY (MaKM) REFERENCES KhuyenMai(MaKM) ON DELETE SET NULL
);

-- 19. BẢNG VÉ XEM PHIM (Ve)
CREATE TABLE Ve (
    MaVe INT IDENTITY(1,1) PRIMARY KEY,
    MaDatVe INT NOT NULL,
    MaSuat INT NOT NULL,
    MaGhe INT NOT NULL,
    GiaVe DECIMAL(18,2) NOT NULL,
    MaQR VARCHAR(100) NULL,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đã in',
    CONSTRAINT UQ_Ve_Suat_Ghe UNIQUE (MaSuat, MaGhe),
    CONSTRAINT FK_Ve_HoaDon FOREIGN KEY (MaDatVe) REFERENCES HoaDon(MaDatVe) ON DELETE CASCADE,
    CONSTRAINT FK_Ve_SuatChieu FOREIGN KEY (MaSuat) REFERENCES SuatChieu(MaSuat),
    CONSTRAINT FK_Ve_Ghe FOREIGN KEY (MaGhe) REFERENCES Ghe(MaGhe)
);

-- 20. BẢNG CHI TIẾT HÓA ĐƠN BẮP NƯỚC (ChiTietHoaDon)
CREATE TABLE ChiTietHoaDon (
    MaChiTiet INT IDENTITY(1,1) PRIMARY KEY,
    MaDatVe INT NOT NULL,
    MaSP INT NULL,
    MaCombo INT NULL,
    SoLuong INT NOT NULL DEFAULT 1,
    DonGia DECIMAL(18,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_CTHD_HoaDon FOREIGN KEY (MaDatVe) REFERENCES HoaDon(MaDatVe) ON DELETE CASCADE,
    CONSTRAINT FK_CTHD_SanPham FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
    CONSTRAINT FK_CTHD_Combo FOREIGN KEY (MaCombo) REFERENCES Combo(MaCombo)
);

-- 21. BẢNG GIAO DỊCH THANH TOÁN (ThanhToan)
CREATE TABLE ThanhToan (
    MaThanhToan INT IDENTITY(1,1) PRIMARY KEY,
    MaDatVe INT NOT NULL,
    SoTien DECIMAL(18,2) NOT NULL DEFAULT 0,
    PhuongThuc NVARCHAR(50) NOT NULL DEFAULT N'Tiền mặt', -- 'Tiền mặt', 'Chuyển khoản QR', 'Thẻ POS'
    NgayThanhToan DATETIME NOT NULL DEFAULT GETDATE(),
    TrangThai NVARCHAR(50) NOT NULL DEFAULT N'Thành công',
    CONSTRAINT FK_TT_HoaDon FOREIGN KEY (MaDatVe) REFERENCES HoaDon(MaDatVe) ON DELETE CASCADE
);
GO

PRINT N'==> Đã tạo thành công toàn bộ 21 BẢNG THỰC THỂ chuẩn 100%!';
GO
