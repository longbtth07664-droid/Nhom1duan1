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
-- PHẦN 1: XÓA DATABASE CŨ (NẾU CÓ) & TẠO LẠI DATABASE MỚI HOÀN TOÀN TỪ ĐẦU
-- ----------------------------------------------------------------------------
USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = N'QuanLyDatVeRapPhim')
BEGIN
    ALTER DATABASE QuanLyDatVeRapPhim SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyDatVeRapPhim;
    PRINT N'==> Đã xóa sạch Database cũ: QuanLyDatVeRapPhim';
END
GO

CREATE DATABASE QuanLyDatVeRapPhim;
PRINT N'==> Đã khởi tạo mới hoàn toàn Cơ sở dữ liệu: QuanLyDatVeRapPhim';
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
-- Giữ cả LoaiPhong (code hiện tại đang map) và MaLoaiPhong (mở rộng) để không lỗi bất kỳ chức năng nào
CREATE TABLE PhongChieu (
    MaPhong INT IDENTITY(1,1) PRIMARY KEY,
    TenPhong NVARCHAR(100) NOT NULL,                  -- 'Phòng 01 - Tiêu Chuẩn'
    LoaiPhong NVARCHAR(50) NULL DEFAULT N'2D',        -- Khớp PhongChieu.java (@Column LoaiPhong)
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
-- Giữ cả DinhDang (code hiện tại đang map) và MaDinhDang NULL (cho phần nâng cấp)
CREATE TABLE SuatChieu (
    MaSuat INT IDENTITY(1,1) PRIMARY KEY,
    MaPhim INT NOT NULL,
    MaPhong INT NOT NULL,
    DinhDang NVARCHAR(20) NOT NULL DEFAULT N'2D',     -- Khớp SuatChieu.java (@Column DinhDang)
    MaDinhDang INT NULL,
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

-- 14. BẢNG KHUYẾN MÃI / VOUCHER (KhuyenMai) - NÂNG CẤP ĐIỀU KIỆN THEO GIỜ VÀ ĐỘ TUỔI
CREATE TABLE KhuyenMai (
    MaKM INT IDENTITY(1,1) PRIMARY KEY,
    TenKM NVARCHAR(100) NOT NULL,
    MaCode VARCHAR(50) NOT NULL UNIQUE,
    PhanTramGiam DECIMAL(5,2) NOT NULL DEFAULT 0,
    SoTienGiamToiDa DECIMAL(18,2) NOT NULL DEFAULT 0,
    DonToiThieu DECIMAL(18,2) NOT NULL DEFAULT 0,
    
    -- Điều kiện Khung giờ chiếu (Theo giờ)
    GioChieuTu TIME NULL,                             -- Khung giờ từ (VD: 08:00 cho Early Bird)
    GioChieuDen TIME NULL,                            -- Khung giờ đến (VD: 12:00)
    
    -- Điều kiện Thứ trong tuần ('2,3,4,5,6,7,CN' hoặc 'ALL')
    ThuTrongTuan VARCHAR(50) NULL DEFAULT 'ALL',
    
    -- Điều kiện Độ tuổi (Theo tuổi khách hàng)
    TuoiToiThieu INT NULL,                            -- Tuổi từ (VD: 12 tuổi)
    TuoiToiDa INT NULL,                               -- Tuổi đến (VD: 22 tuổi cho HSSV/U22)
    
    -- Điều kiện Số lượng vé tối thiểu & Định dạng
    SoVeToiThieu INT NOT NULL DEFAULT 1,
    MaDinhDangApDung INT NULL,                        -- NULL = Áp dụng mọi định dạng
    
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

-- ----------------------------------------------------------------------------
-- PHẦN 4: DỮ LIỆU MẪU CHUẨN ĐẦY ĐỦ (CHẠY XONG LÀ TEST ĐƯỢC MỌI CHỨC NĂNG NGAY)
-- ----------------------------------------------------------------------------

-- 1. Tài khoản đăng nhập (Admin & Nhân viên)
INSERT INTO TaiKhoan (HoTen, CCCD, Email, SoDienThoai, DiaChi, VaiTro, Username, Password, TrangThai) VALUES
(N'Nguyễn Quản Lý', '001200000001', 'admin@cinemax.vn', '0901000001', N'Hà Nội', N'QuanLy', 'admin', '123456', N'Hoạt động'),
(N'Trần Thu Ngân',  '001200000002', 'nv1@cinemax.vn',   '0901000002', N'Hà Nội', N'NhanVien', 'nv1',   '123456', N'Hoạt động'),
(N'Lê Soát Vé',     '001200000003', 'nv2@cinemax.vn',   '0901000003', N'Hà Nội', N'NhanVien', 'nv2',   '123456', N'Hoạt động');

-- 2. Khách hàng thành viên (Có sẵn Ngày sinh để test Voucher U22 & Người cao tuổi)
INSERT INTO KhachHang (MaKH, HoTen, SDT, DiemTichLuy, GioiTinh, NgaySinh) VALUES
(N'KH001', N'Phạm Sinh Viên (U22)', '0911111111', 50,  N'Nam', '2005-05-15'),
(N'KH002', N'Nguyễn Khách VIP',     '0922222222', 200, N'Nữ',  '1995-08-20'),
(N'KH003', N'Lê Cao Tuổi (60+)',    '0933333333', 80,  N'Nam', '1960-01-10');

-- 3. Thể loại phim
INSERT INTO TheLoai (TenTheLoai) VALUES
(N'Hành Động'), (N'Tình Cảm'), (N'Hoạt Hình'), (N'Kinh Dị'), (N'Khoa Học Viễn Tưởng'), (N'Hài Hước');

-- 4. Phim (Gồm Đang chiếu, Sắp chiếu, Ngừng chiếu)
INSERT INTO Phim (TenPhim, MoTa, ThoiLuong, NgayKhoiChieu, NgayKetThuc, DaoDien, DienVien, QuocGia, Poster, Trailer, DoTuoi, TrangThai) VALUES
(N'Avatar: Dòng Chảy Của Nước', N'Siêu phẩm hành động viễn tưởng thế giới Pandora.', 192, DATEADD(day, -10, GETDATE()), DATEADD(day, 30, GETDATE()), N'James Cameron', N'Sam Worthington, Zoe Saldana', N'Mỹ', 'avatar2.jpg', '', 'P', N'Đang chiếu'),
(N'Mai', N'Phim tâm lý tình cảm Việt Nam.', 131, DATEADD(day, -7, GETDATE()), DATEADD(day, 25, GETDATE()), N'Trấn Thành', N'Phương Anh Đào, Tuấn Trần', N'Việt Nam', 'mai.jpg', '', 'T18', N'Đang chiếu'),
(N'Kung Fu Panda 4', N'Chú gấu trúc Po trở lại với hành trình mới.', 94, DATEADD(day, -5, GETDATE()), DATEADD(day, 20, GETDATE()), N'Mike Mitchell', N'Jack Black', N'Mỹ', 'panda4.jpg', '', 'P', N'Đang chiếu'),
(N'The Odyssey (Sắp chiếu)', N'Bom tấn sử thi Hy Lạp.', 173, DATEADD(day, 15, GETDATE()), DATEADD(day, 60, GETDATE()), N'Christopher Nolan', N'Matt Damon', N'Mỹ', 'odyssey.jpg', '', 'T13', N'Sắp chiếu'),
(N'Kẻ Hồi Sinh (Ngừng chiếu)', N'Phim hành động đã hết hạn chiếu.', 101, DATEADD(day, -60, GETDATE()), DATEADD(day, -10, GETDATE()), N'Jong-Yeol Baek', N'Lee Dong-Wook', N'Hàn Quốc', 'kehoisinh.jpg', '', 'T16', N'Ngừng chiếu');

-- Gán thể loại cho phim
INSERT INTO Phim_TheLoai (MaPhim, MaTheLoai) VALUES (1, 1), (1, 5), (2, 2), (3, 3), (3, 6), (4, 1), (5, 1);

-- 5. Loại phòng & Phòng chiếu
INSERT INTO LoaiPhong (MaLoaiPhong, TenLoaiPhong) VALUES
('STANDARD',   N'Phòng Tiêu Chuẩn'),
('3D_ROOM',    N'Phòng Chiếu 3D'),
('IMAX',       N'Phòng Công Nghệ IMAX');

INSERT INTO PhongChieu (TenPhong, LoaiPhong, MaLoaiPhong, SucChua) VALUES
(N'Phòng 01 - Standard', N'2D',   'STANDARD', 40),
(N'Phòng 02 - 3D',       N'3D',   '3D_ROOM',  40),
(N'Phòng 03 - IMAX',     N'IMAX', 'IMAX',     40);

-- 6. Định dạng trình chiếu & Liên kết Phòng - Định dạng, Phim - Định dạng
INSERT INTO DinhDang (TenDinhDang, PhuThu) VALUES
(N'2D',      0),
(N'3D',      30000),
(N'IMAX 2D', 50000),
(N'IMAX 3D', 80000);

INSERT INTO Phong_DinhDang (MaPhong, MaDinhDang) VALUES
(1, 1),          -- Phòng 1: 2D
(2, 1), (2, 2),  -- Phòng 2: 2D, 3D
(3, 3), (3, 4);  -- Phòng 3: IMAX 2D, IMAX 3D

INSERT INTO Phim_DinhDang (MaPhim, MaDinhDang) VALUES
(1, 1), (1, 2), (1, 4), -- Avatar: 2D, 3D, IMAX 3D
(2, 1),                 -- Mai: chỉ 2D
(3, 1), (3, 2);         -- Panda 4: 2D, 3D

-- 7. Loại ghế & Tự động sinh 40 ghế/phòng (Hàng A, B, C, D, E - mỗi hàng 8 ghế)
INSERT INTO LoaiGhe (TenLoaiGhe, PhuThu) VALUES
(N'Thường',           0),
(N'VIP',              20000),
(N'Đôi (Sweetbox)',   50000);

DECLARE @p INT = 1;
WHILE @p <= 3
BEGIN
    DECLARE @rowIdx INT = 1;
    WHILE @rowIdx <= 5
    BEGIN
        DECLARE @hang VARCHAR(5) = CHAR(64 + @rowIdx); -- A, B, C, D, E
        DECLARE @maLoaiGhe INT = CASE WHEN @rowIdx IN (3, 4) THEN 2 WHEN @rowIdx = 5 THEN 3 ELSE 1 END;
        DECLARE @so INT = 1;
        WHILE @so <= 8
        BEGIN
            INSERT INTO Ghe (MaPhong, MaLoaiGhe, HangGhe, SoGhe, TrangThai)
            VALUES (@p, @maLoaiGhe, @hang, @so, N'Hoạt động');
            SET @so = @so + 1;
        END
        SET @rowIdx = @rowIdx + 1;
    END
    SET @p = @p + 1;
END

-- 8. Suất chiếu mẫu cho Hôm nay và Ngày mai (bao gồm cả suất sáng sớm & khuya để test Voucher)
DECLARE @Today DATE = CAST(GETDATE() AS DATE);
DECLARE @Tomorrow DATE = DATEADD(day, 1, @Today);

INSERT INTO SuatChieu (MaPhim, MaPhong, DinhDang, MaDinhDang, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai) VALUES
(3, 1, N'2D',   1, @Today,    '09:30:00', '11:20:00', 75000,  N'Đang mở bán'),
(2, 1, N'2D',   1, @Today,    '14:00:00', '16:25:00', 85000,  N'Đang mở bán'),
(1, 2, N'3D',   2, @Today,    '19:30:00', '22:55:00', 110000, N'Đang mở bán'),
(1, 3, N'IMAX', 4, @Today,    '22:30:00', '01:55:00', 150000, N'Đang mở bán'),
(2, 1, N'2D',   1, @Tomorrow, '10:00:00', '12:25:00', 80000,  N'Đang mở bán'),
(1, 2, N'3D',   2, @Tomorrow, '20:00:00', '23:25:00', 110000, N'Đang mở bán');

-- 9. Sản phẩm F&B (Lưu ý: TrangThai = N'Đang kinh doanh' để khớp SanPhamRepository)
INSERT INTO SanPham (TenSP, LoaiSP, DonViTinh, GiaBan, SoLuongTon, TrangThai, HinhAnh) VALUES
(N'Bắp Rang Bơ Lớn', N'Bắp rang', N'Hộp',  55000, 100, N'Đang kinh doanh', 'bap_lon.jpg'),
(N'Pepsi Tươi Lớn',  N'Nước ngọt', N'Ly',  35000, 150, N'Đang kinh doanh', 'pepsi.jpg'),
(N'Coca-Cola Lớn',   N'Nước ngọt', N'Ly',  35000, 150, N'Đang kinh doanh', 'coca.jpg'),
(N'Nước Suối',       N'Nước suối', N'Chai', 20000, 200, N'Đang kinh doanh', 'nuoc_suoi.jpg');

-- 10. Combo & Chi tiết Combo
INSERT INTO Combo (TenCombo, GiaCombo, MoTa, HinhAnh, TrangThai) VALUES
(N'Combo Solo',   79000,  N'1 Bắp Rang Bơ Lớn + 1 Pepsi Tươi Lớn', 'combo_solo.jpg', N'Đang bán'),
(N'Combo Couple', 109000, N'1 Bắp Rang Bơ Lớn + 2 Pepsi Tươi Lớn', 'combo_couple.jpg', N'Đang bán');

INSERT INTO ChiTietCombo (MaCombo, MaSP, SoLuong, GhiChu) VALUES
(1, 1, 1, N'Vị phô mai hoặc caramel'),
(1, 2, 1, N'Ít đá'),
(2, 1, 1, N'Vị bơ truyền thống'),
(2, 2, 2, N'2 ly lớn');

-- 11. Khuyến mãi / Voucher (Theo Giờ chiếu, Thứ, Độ tuổi)
INSERT INTO KhuyenMai (TenKM, MaCode, PhanTramGiam, SoTienGiamToiDa, DonToiThieu, GioChieuTu, GioChieuDen, ThuTrongTuan, TuoiToiThieu, TuoiToiDa, SoVeToiThieu, NgayBatDau, NgayKetThuc, TrangThai) VALUES
(N'Ưu Đãi HSSV / U22',       'U22_STUDENT', 20.00, 50000,  0,      NULL,       NULL,       'ALL', 12,   22,   1, GETDATE(), DATEADD(year, 1, GETDATE()), N'Đang áp dụng'),
(N'Suất Chiếu Sớm Early Bird','EARLY_BIRD',  15.00, 40000,  0,      '08:00:00', '12:00:00', 'ALL', NULL, NULL, 1, GETDATE(), DATEADD(year, 1, GETDATE()), N'Đang áp dụng'),
(N'Suất Chiếu Khuya Midnight','MIDNIGHT',    25.00, 60000,  0,      '22:00:00', '23:59:59', 'ALL', NULL, NULL, 1, GETDATE(), DATEADD(year, 1, GETDATE()), N'Đang áp dụng'),
(N'Thứ 3 Vui Vẻ',             'HAPPY_TUE',   20.00, 50000,  0,      NULL,       NULL,       '3',   NULL, NULL, 1, GETDATE(), DATEADD(year, 1, GETDATE()), N'Đang áp dụng'),
(N'Tri Ân Người Cao Tuổi',    'SENIOR_60',   30.00, 70000,  0,      NULL,       NULL,       'ALL', 60,   120,  1, GETDATE(), DATEADD(year, 1, GETDATE()), N'Đang áp dụng');
GO

PRINT N'==> Đã khởi tạo toàn bộ 21 BẢNG + DỮ LIỆU MẪU ĐẦY ĐỦ thành công!';
GO
