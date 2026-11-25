-- ============================================================================
-- DỰ ÁN 1: HỆ THỐNG QUẢN LÝ VÀ ĐẶT VÉ RẠP CHIẾU PHIM CINEMAX
-- HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU: MICROSOFT SQL SERVER 2016+
-- TÊN DATABASE: QuanLyDatVeRapPhim
-- PHIÊN BẢN: HOÀN CHỈNH 100% (CHUẨN HÓA TOÀN BỘ 16 BẢNG THỰC THỂ)
-- Bao quát toàn bộ nghiệp vụ:
--   1. Phân quyền & Nhân sự (TaiKhoan / NhanVien)
--   2. Khách hàng thân thiết & Điểm tích lũy (KhachHang)
--   3. Phim & Thể loại (Phim, TheLoai, Phim_TheLoai)
--   4. Phòng chiếu & Ghế ngồi (LoaiPhong, PhongChieu, LoaiGhe, Ghe)
--   5. Lịch chiếu & Suất chiếu (SuatChieu)
--   6. Quầy Bắp Nước & Gói Combo Ưu Đãi (SanPham, Combo, ChiTietCombo)
--   7. Bán vé POS, Hóa đơn, Vé điện tử & Thanh toán (HoaDon, Ve, ChiTietHoaDon, ThanhToan)
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
-- PHẦN 2: DỌN DẸP BẢNG CŨ THEO THỨ TỰ RÀNG BUỘC (NẾU CẦN TÁI TẠO TỪ ĐẦU)
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.ThanhToan', N'U') IS NOT NULL DROP TABLE dbo.ThanhToan;
IF OBJECT_ID(N'dbo.ChiTietHoaDon', N'U') IS NOT NULL DROP TABLE dbo.ChiTietHoaDon;
IF OBJECT_ID(N'dbo.Ve', N'U') IS NOT NULL DROP TABLE dbo.Ve;
IF OBJECT_ID(N'dbo.HoaDon', N'U') IS NOT NULL DROP TABLE dbo.HoaDon;
IF OBJECT_ID(N'dbo.ChiTietCombo', N'U') IS NOT NULL DROP TABLE dbo.ChiTietCombo;
IF OBJECT_ID(N'dbo.Combo', N'U') IS NOT NULL DROP TABLE dbo.Combo;
IF OBJECT_ID(N'dbo.SanPham', N'U') IS NOT NULL DROP TABLE dbo.SanPham;
IF OBJECT_ID(N'dbo.SuatChieu', N'U') IS NOT NULL DROP TABLE dbo.SuatChieu;
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
-- PHẦN 3: ĐỊNH NGHĨA CẤU TRÚC 16 BẢNG DỮ LIỆU (DDL)
-- ----------------------------------------------------------------------------

-- 1. BẢNG TÀI KHOẢN / NHÂN VIÊN (TaiKhoan)
-- Dùng cho xác thực đăng nhập, phân quyền quản lý & nhân viên thu ngân
CREATE TABLE TaiKhoan (
    MaTK INT IDENTITY(1,1) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    CCCD VARCHAR(20) NULL UNIQUE,
    Email VARCHAR(100) NULL UNIQUE,
    SoDienThoai VARCHAR(15) NULL,
    DiaChi NVARCHAR(255) NULL,
    VaiTro NVARCHAR(30) NOT NULL,                           -- 'QuanLy', 'NhanVien'
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đang làm việc'-- 'Đang làm việc', 'Nghỉ việc'
);
GO

-- 2. BẢNG KHÁCH HÀNG THÀNH VIÊN (KhachHang)
-- Quản lý hội viên, số điện thoại tra cứu tại POS và điểm thưởng tích lũy
CREATE TABLE KhachHang (
    MaKH NVARCHAR(20) PRIMARY KEY,                          -- VD: 'KH001', 'KH002'
    HoTen NVARCHAR(100) NOT NULL,
    SDT VARCHAR(15) NOT NULL UNIQUE,                        -- Khóa duy nhất tìm kiếm tại quầy POS
    DiemTichLuy INT NOT NULL DEFAULT 0,                     -- Điểm thưởng tích lũy
    GioiTinh NVARCHAR(10) NULL DEFAULT N'Khác'              -- 'Nam', 'Nữ', 'Khác'
);
GO

-- 3. BẢNG THỂ LOẠI PHIM (TheLoai)
CREATE TABLE TheLoai (
    MaTheLoai INT IDENTITY(1,1) PRIMARY KEY,
    TenTheLoai NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- 4. BẢNG BỘ PHIM (Phim)
CREATE TABLE Phim (
    MaPhim INT IDENTITY(1,1) PRIMARY KEY,
    TenPhim NVARCHAR(200) NOT NULL,
    MoTa NVARCHAR(MAX) NULL,
    ThoiLuong INT NOT NULL,                                 -- Thời lượng (phút)
    NgayKhoiChieu DATE NOT NULL,
    NgayKetThuc DATE NULL,
    DaoDien NVARCHAR(100) NULL,
    DienVien NVARCHAR(255) NULL,
    QuocGia NVARCHAR(50) NULL DEFAULT N'Việt Nam',
    Poster VARCHAR(255) NULL,                               -- Tên tệp ảnh trong assets/images/
    Trailer VARCHAR(255) NULL,                              -- Link trailer youtube
    DoTuoi VARCHAR(10) NULL DEFAULT 'P',                    -- 'P', 'K', 'T13', 'T16', 'T18', 'C'
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đang chiếu'   -- 'Sắp chiếu', 'Đang chiếu', 'Ngừng chiếu'
);
GO

-- 5. BẢNG TRUNG GIAN PHIM - THỂ LOẠI (Phim_TheLoai)
CREATE TABLE Phim_TheLoai (
    MaPhim INT NOT NULL,
    MaTheLoai INT NOT NULL,
    PRIMARY KEY (MaPhim, MaTheLoai),
    CONSTRAINT FK_PTL_Phim FOREIGN KEY (MaPhim) REFERENCES Phim(MaPhim) ON DELETE CASCADE,
    CONSTRAINT FK_PTL_TheLoai FOREIGN KEY (MaTheLoai) REFERENCES TheLoai(MaTheLoai) ON DELETE CASCADE
);
GO

-- 6. BẢNG LOẠI PHÒNG CHIẾU (LoaiPhong)
CREATE TABLE LoaiPhong (
    MaLoaiPhong VARCHAR(50) PRIMARY KEY,                    -- '2D', '3D', 'IMAX', 'GOLD'
    TenLoaiPhong NVARCHAR(100) NOT NULL
);
GO

-- 7. BẢNG PHÒNG CHIẾU (PhongChieu)
CREATE TABLE PhongChieu (
    MaPhong INT IDENTITY(1,1) PRIMARY KEY,
    TenPhong NVARCHAR(100) NOT NULL,                        -- VD: 'Phòng 01 - Tiêu Chuẩn'
    LoaiPhong NVARCHAR(50) NULL,                            -- Khớp tên hoặc mã loại phòng
    SucChua INT NOT NULL DEFAULT 0
);
GO

-- 8. BẢNG LOẠI GHẾ (LoaiGhe)
CREATE TABLE LoaiGhe (
    MaLoaiGhe INT IDENTITY(1,1) PRIMARY KEY,
    TenLoaiGhe NVARCHAR(50) NOT NULL,                       -- 'Ghế Thường', 'Ghế VIP', 'Ghế Đôi Sweetbox'
    PhuThu DECIMAL(18,2) NOT NULL DEFAULT 0                 -- Tiền phụ thu (VNĐ)
);
GO

-- 9. BẢNG GHẾ VẬT LÝ (Ghe)
CREATE TABLE Ghe (
    MaGhe INT IDENTITY(1,1) PRIMARY KEY,
    MaPhong INT NOT NULL,
    MaLoaiGhe INT NOT NULL,
    HangGhe VARCHAR(5) NOT NULL,                            -- A, B, C, D, E, F, G, H...
    SoGhe INT NOT NULL,                                     -- 1, 2, 3...
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Hoạt động',   -- 'Hoạt động', 'Bảo trì'
    CONSTRAINT FK_Ghe_Phong FOREIGN KEY (MaPhong) REFERENCES PhongChieu(MaPhong) ON DELETE CASCADE,
    CONSTRAINT FK_Ghe_Loai FOREIGN KEY (MaLoaiGhe) REFERENCES LoaiGhe(MaLoaiGhe),
    CONSTRAINT UQ_Ghe_PhongHangSo UNIQUE (MaPhong, HangGhe, SoGhe)
);
GO

-- 10. BẢNG SUẤT CHIẾU (SuatChieu)
CREATE TABLE SuatChieu (
    MaSuat INT IDENTITY(1,1) PRIMARY KEY,
    MaPhim INT NOT NULL,
    MaPhong INT NOT NULL,
    DinhDang NVARCHAR(20) NOT NULL DEFAULT N'2D',           -- '2D', '3D', 'IMAX Laser'
    NgayChieu DATE NOT NULL,
    GioBatDau TIME(0) NOT NULL,
    GioKetThuc TIME(0) NOT NULL,
    GiaVeCoBan DECIMAL(18,2) NOT NULL DEFAULT 80000,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đang mở bán', -- 'Sắp mở bán', 'Đang mở bán', 'Đã kết thúc', 'Đã hủy'
    LyDoHuy NVARCHAR(255) NULL,
    CONSTRAINT FK_Suat_Phim FOREIGN KEY (MaPhim) REFERENCES Phim(MaPhim),
    CONSTRAINT FK_Suat_Phong FOREIGN KEY (MaPhong) REFERENCES PhongChieu(MaPhong)
);
GO

-- 11. BẢNG SẢN PHẨM BẮP NƯỚC (SanPham)
CREATE TABLE SanPham (
    MaSP INT IDENTITY(1,1) PRIMARY KEY,
    TenSP NVARCHAR(100) NOT NULL,
    LoaiSP NVARCHAR(50) NOT NULL,                           -- 'Bắp', 'Nước', 'Snack', 'Khác'
    DonViTinh NVARCHAR(20) NOT NULL,                        -- 'Hộp', 'Ly', 'Chai', 'Gói'
    GiaBan DECIMAL(18,0) NOT NULL DEFAULT 0,
    SoLuongTon INT NOT NULL DEFAULT 0,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đang bán',    -- 'Đang bán', 'Ngừng bán'
    HinhAnh NVARCHAR(255) NULL
);
GO

-- 12. BẢNG GÓI COMBO ƯU ĐÃI (Combo)
CREATE TABLE Combo (
    MaCombo INT IDENTITY(1,1) PRIMARY KEY,
    TenCombo NVARCHAR(100) NOT NULL,
    GiaCombo DECIMAL(18,0) NOT NULL DEFAULT 0,
    MoTa NVARCHAR(255) NULL,
    HinhAnh NVARCHAR(255) NULL,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đang bán'     -- 'Đang bán', 'Ngừng bán'
);
GO

-- 13. BẢNG CHI TIẾT GÓI COMBO (ChiTietCombo)
CREATE TABLE ChiTietCombo (
    MaCombo INT NOT NULL,
    MaSP INT NOT NULL,
    SoLuong INT NOT NULL DEFAULT 1,
    GhiChu NVARCHAR(100) NULL,
    PRIMARY KEY (MaCombo, MaSP),
    CONSTRAINT FK_CTC_Combo FOREIGN KEY (MaCombo) REFERENCES Combo(MaCombo) ON DELETE CASCADE,
    CONSTRAINT FK_CTC_SP FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

-- 14. BẢNG HÓA ĐƠN GIAO DỊCH (HoaDon)
CREATE TABLE HoaDon (
    MaDatVe INT IDENTITY(1,1) PRIMARY KEY,
    MaTK INT NOT NULL,                                      -- Thu ngân lập đơn
    MaKH NVARCHAR(20) NULL,                                 -- Thành viên tích điểm
    MaKM INT NULL,                                          -- Mã khuyến mãi / voucher
    NgayDat DATETIME NOT NULL DEFAULT GETDATE(),            -- Thời gian bán hàng
    TongTien DECIMAL(18,2) NOT NULL DEFAULT 0,              -- Tổng thực thu
    TienGiam DECIMAL(18,2) NOT NULL DEFAULT 0,              -- Giảm giá tích lũy / KM
    TrangThai NVARCHAR(50) NOT NULL DEFAULT N'Đã hoàn tất', -- 'Đã hoàn tất', 'Chờ thanh toán', 'Đã hủy'
    CONSTRAINT FK_HD_TaiKhoan FOREIGN KEY (MaTK) REFERENCES TaiKhoan(MaTK),
    CONSTRAINT FK_HD_KhachHang FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH) ON DELETE SET NULL
);
GO

-- 15. BẢNG VÉ XEM PHIM (Ve)
CREATE TABLE Ve (
    MaVe INT IDENTITY(1,1) PRIMARY KEY,
    MaDatVe INT NOT NULL,
    MaSuat INT NOT NULL,
    MaGhe INT NOT NULL,
    GiaVe DECIMAL(18,2) NOT NULL DEFAULT 0,
    MaQR VARCHAR(100) NULL,                                 -- Barcode Code 128 / QR Code
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đã bán',      -- 'Chờ thanh toán', 'Đã bán', 'Đã in', 'Đã check-in', 'Đã hủy'
    CONSTRAINT FK_Ve_HoaDon FOREIGN KEY (MaDatVe) REFERENCES HoaDon(MaDatVe) ON DELETE CASCADE,
    CONSTRAINT FK_Ve_Suat FOREIGN KEY (MaSuat) REFERENCES SuatChieu(MaSuat),
    CONSTRAINT FK_Ve_Ghe FOREIGN KEY (MaGhe) REFERENCES Ghe(MaGhe)
);
GO

-- 16. BẢNG CHI TIẾT HÓA ĐƠN COMBO / BẮP NƯỚC (ChiTietHoaDon)
CREATE TABLE ChiTietHoaDon (
    MaChiTiet INT IDENTITY(1,1) PRIMARY KEY,
    MaDatVe INT NOT NULL,
    MaSP INT NULL,
    MaCombo INT NULL,
    SoLuong INT NOT NULL DEFAULT 1,
    DonGia DECIMAL(18,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_CTHD_HoaDon FOREIGN KEY (MaDatVe) REFERENCES HoaDon(MaDatVe) ON DELETE CASCADE,
    CONSTRAINT FK_CTHD_SP FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
    CONSTRAINT FK_CTHD_Combo FOREIGN KEY (MaCombo) REFERENCES Combo(MaCombo)
);
GO

-- 17. BẢNG THANH TOÁN (ThanhToan)
CREATE TABLE ThanhToan (
    MaThanhToan INT IDENTITY(1,1) PRIMARY KEY,
    MaDatVe INT NOT NULL,
    PhuongThuc NVARCHAR(50) NOT NULL DEFAULT N'Tiền mặt',    -- 'Tiền mặt', 'Chuyển khoản QR', 'Thẻ POS'
    NgayThanhToan DATETIME NOT NULL DEFAULT GETDATE(),
    TrangThai NVARCHAR(50) NOT NULL DEFAULT N'Thành công',  -- 'Thành công', 'Đang xử lý', 'Đã hủy'
    CONSTRAINT FK_TT_HoaDon FOREIGN KEY (MaDatVe) REFERENCES HoaDon(MaDatVe) ON DELETE CASCADE
);
GO

-- ----------------------------------------------------------------------------
-- PHẦN 4: TẠO CÁC CHỈ MỤC INDEX TĂNG TỐC TRUY VẤN
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_KhachHang_SDT ON KhachHang(SDT);
CREATE NONCLUSTERED INDEX IX_SuatChieu_Ngay_Phong ON SuatChieu(NgayChieu, MaPhong, GioBatDau);
CREATE NONCLUSTERED INDEX IX_SuatChieu_Phim ON SuatChieu(MaPhim, NgayChieu);
CREATE NONCLUSTERED INDEX IX_Ve_Suat_Ghe ON Ve(MaSuat, MaGhe);
CREATE NONCLUSTERED INDEX IX_Ve_MaQR ON Ve(MaQR);
CREATE NONCLUSTERED INDEX IX_HoaDon_NgayDat ON HoaDon(NgayDat);
CREATE NONCLUSTERED INDEX IX_ThanhToan_MaDatVe ON ThanhToan(MaDatVe);
GO

PRINT N'==> Đã tạo xong toàn bộ 16 bảng và các chỉ mục Index tối ưu hóa.';
GO

-- ----------------------------------------------------------------------------
-- PHẦN 5: BỘ DỮ LIỆU MẪU CHUẨN MỰC (SEED DATA)
-- ----------------------------------------------------------------------------

SET IDENTITY_INSERT TaiKhoan ON;
INSERT INTO TaiKhoan (MaTK, HoTen, CCCD, Email, SoDienThoai, DiaChi, VaiTro, Username, Password, TrangThai) VALUES
(1, N'Trần Văn Quản', '001202018899', 'quantv@cinemax.vn', '0988123456', N'Hà Nội', 'QuanLy', 'admin_quan', '123456', N'Đang làm việc'),
(2, N'Nguyễn Thu Ngân', '001203019911', 'ngannt@cinemax.vn', '0912345678', N'Hà Nội', 'NhanVien', 'thungan1', '123456', N'Đang làm việc'),
(3, N'Lê Hoàng Nam', '001204017722', 'namlh@cinemax.vn', '0977889900', N'Hà Nội', 'NhanVien', 'thungan2', '123456', N'Đang làm việc');
SET IDENTITY_INSERT TaiKhoan OFF;
GO

INSERT INTO KhachHang (MaKH, HoTen, SDT, DiemTichLuy, GioiTinh) VALUES
('KH001', N'Nguyễn Văn A', '0912345678', 350, N'Nam'),
('KH002', N'Trần Thị Mai', '0987654321', 120, N'Nữ'),
('KH003', N'Lê Minh Khang', '0905112233', 580, N'Nam'),
('KH004', N'Phạm Thu Thảo', '0933445566', 1250, N'Nữ'),
('KH005', N'Đỗ Quốc Hùng', '0966778899', 45, N'Nam');
GO

SET IDENTITY_INSERT TheLoai ON;
INSERT INTO TheLoai (MaTheLoai, TenTheLoai) VALUES
(1, N'Hành động'),
(2, N'Tình cảm'),
(3, N'Hài hước'),
(4, N'Kinh dị'),
(5, N'Hoạt hình'),
(6, N'Khoa học viễn tưởng'),
(7, N'Tâm lý - Xã hội');
SET IDENTITY_INSERT TheLoai OFF;
GO

SET IDENTITY_INSERT Phim ON;
INSERT INTO Phim (MaPhim, TenPhim, MoTa, ThoiLuong, NgayKhoiChieu, NgayKetThuc, DaoDien, DienVien, QuocGia, Poster, Trailer, DoTuoi, TrangThai) VALUES
(1, N'Đào, Phở và Piano', N'Câu chuyện tình yêu xúc động giữa chàng dân quân và cô tiểu thư Hà thành trong khói lửa kháng chiến cuối năm 1946.', 100, '2026-02-10', '2026-12-30', N'Phi Tiến Sơn', N'Doãn Quốc Đam, Cao Thùy Linh, NSND Trung Hiếu', N'Việt Nam', 'dao-pho-piano.jpg', 'https://youtube.com/watch?v=sample1', 'T13', N'Đang chiếu'),
(2, N'Mai', N'Một người phụ nữ với số phận trớ trêu khao khát tình yêu chân thực và cơ hội chữa lành vết thương lòng.', 131, '2026-02-10', '2026-12-30', N'Trấn Thành', N'Phương Anh Đào, Tuấn Trần, Hồng Đào', N'Việt Nam', 'mai.jpg', 'https://youtube.com/watch?v=sample2', 'T18', N'Đang chiếu'),
(3, N'Kung Fu Panda 4', N'Po bước vào hành trình mới tìm kiếm người kế thừa vị trí Thần Long Đại Hiệp và đối đầu với mụ phù thủy Tắc Kè Hoa xảo quyệt.', 94, '2026-03-08', '2026-12-30', N'Mike Mitchell', N'Jack Black, Awkwafina, Viola Davis', N'Mỹ', 'kungfu-panda-4.jpg', 'https://youtube.com/watch?v=sample3', 'P', N'Đang chiếu'),
(4, N'Godzilla x Kong: Đế Chế Mới', N'Hai quái thú khổng lồ huyền thoại hợp sức chống lại mối hiểm họa đen tối trỗi dậy từ lòng Trái Đất Rỗng.', 115, '2026-03-29', '2026-12-30', N'Adam Wingard', N'Rebecca Hall, Brian Tyree Henry, Dan Stevens', N'Mỹ', 'godzilla-kong.jpg', 'https://youtube.com/watch?v=sample4', 'T13', N'Đang chiếu'),
(5, N'Exhuma: Quật Mộ Trùng Ma', N'Hai pháp sư trẻ cùng thầy phong thủy và chuyên gia tang lễ khai quật một ngôi mộ bí ẩn với những bí mật kinh hoàng.', 134, '2026-03-15', '2026-12-30', N'Jang Jae-hyun', N'Choi Min-sik, Kim Go-eun, Lee Do-hyun', N'Hàn Quốc', 'exhuma.jpg', 'https://youtube.com/watch?v=sample5', 'T16', N'Đang chiếu'),
(6, N'Dune: Hành Tinh Cát - Phần 2', N'Paul Atreides hợp nhất với Chani và tộc người Fremen để trả thù những kẻ đã hủy diệt gia tộc của mình.', 166, '2026-03-01', '2026-12-30', N'Denis Villeneuve', N'Timothée Chalamet, Zendaya, Rebecca Ferguson', N'Mỹ', 'dune-2.jpg', 'https://youtube.com/watch?v=sample6', 'T16', N'Đang chiếu');
SET IDENTITY_INSERT Phim OFF;
GO

INSERT INTO Phim_TheLoai (MaPhim, MaTheLoai) VALUES
(1, 2), (1, 7),
(2, 2), (2, 7),
(3, 5), (3, 3), (3, 1),
(4, 1), (4, 6),
(5, 4), (5, 7),
(6, 1), (6, 6);
GO

INSERT INTO LoaiPhong (MaLoaiPhong, TenLoaiPhong) VALUES
('2D', N'Phòng Chiếu 2D Tiêu Chuẩn'),
('3D', N'Phòng Chiếu 3D Digital'),
('IMAX', N'Phòng Chiếu IMAX Laser');
GO

SET IDENTITY_INSERT PhongChieu ON;
INSERT INTO PhongChieu (MaPhong, TenPhong, LoaiPhong, SucChua) VALUES
(1, N'Phòng 01 - Tiêu Chuẩn', '2D', 96),
(2, N'Phòng 02 - 3D Digital', '3D', 96),
(3, N'Phòng 03 - IMAX Laser', 'IMAX', 96);
SET IDENTITY_INSERT PhongChieu OFF;
GO

SET IDENTITY_INSERT LoaiGhe ON;
INSERT INTO LoaiGhe (MaLoaiGhe, TenLoaiGhe, PhuThu) VALUES
(1, N'Ghế Thường', 0),
(2, N'Ghế VIP', 15000),
(3, N'Ghế Đôi Sweetbox', 35000);
SET IDENTITY_INSERT LoaiGhe OFF;
GO

-- TẠO SƠ ĐỒ GHẾ NGỒI TỰ ĐỘNG CHO CẢ 3 PHÒNG CHIẾU (CHUẨN TẬP HỢP T-SQL KHÔNG DÙNG VÒNG LẶP)
-- Quy cách mỗi phòng (96 ghế/phòng x 3 phòng = 288 ghế chuẩn):
--   Hàng A, B, C: 12 Ghế Thường (MaLoaiGhe = 1, phụ thu 0đ)     -> 36 ghế
--   Hàng D, E, F, G: 12 Ghế VIP (MaLoaiGhe = 2, phụ thu 15.000đ) -> 48 ghế (D6: MaGhe=42, D5: MaGhe=41)
--   Hàng H: 12 Ghế Đôi Sweetbox (MaLoaiGhe = 3, phụ thu 35.000đ) -> 12 ghế
INSERT INTO Ghe (MaPhong, MaLoaiGhe, HangGhe, SoGhe, TrangThai)
SELECT p.MaPhong,
       CASE 
           WHEN h.Hang IN ('A', 'B', 'C') THEN 1
           WHEN h.Hang IN ('D', 'E', 'F', 'G') THEN 2
           ELSE 3
       END AS MaLoaiGhe,
       h.Hang,
       s.SoGhe,
       N'Hoạt động'
FROM (VALUES (1), (2), (3)) AS p(MaPhong)
CROSS JOIN (VALUES ('A'), ('B'), ('C'), ('D'), ('E'), ('F'), ('G'), ('H')) AS h(Hang)
CROSS JOIN (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) AS s(SoGhe)
ORDER BY p.MaPhong, h.Hang, s.SoGhe;
GO

-- BẢNG SẢN PHẨM BẮP NƯỚC BÁN LẺ
SET IDENTITY_INSERT SanPham ON;
INSERT INTO SanPham (MaSP, TenSP, LoaiSP, DonViTinh, GiaBan, SoLuongTon, TrangThai, HinhAnh) VALUES
(1, N'Bắp Rang Bơ Truyền Thống', N'Bắp', N'Hộp', 45000, 350, N'Đang bán', 'bap-bo.jpg'),
(2, N'Bắp Phô Mai Đặc Biệt', N'Bắp', N'Hộp', 55000, 280, N'Đang bán', 'bap-phomai.jpg'),
(3, N'Bắp Caramen Ngọt Ngào', N'Bắp', N'Hộp', 55000, 310, N'Đang bán', 'bap-caramen.jpg'),
(4, N'Pepsi Tươi Cỡ Lớn', N'Nước', N'Ly', 30000, 500, N'Đang bán', 'pepsi.jpg'),
(5, N'Coca Cola Zero Cỡ Lớn', N'Nước', N'Ly', 30000, 420, N'Đang bán', 'coca.jpg'),
(6, N'Trà Đào Cam Sả', N'Nước', N'Ly', 40000, 200, N'Đang bán', 'tra-dao.jpg'),
(7, N'Nước Suối Aquafina 500ml', N'Nước', N'Chai', 15000, 600, N'Đang bán', 'aquafina.jpg'),
(8, N'Snack Khoai Tây Lays', N'Snack', N'Gói', 25000, 250, N'Đang bán', 'lays.jpg');
SET IDENTITY_INSERT SanPham OFF;
GO

-- BẢNG COMBO ƯU ĐÃI
SET IDENTITY_INSERT Combo ON;
INSERT INTO Combo (MaCombo, TenCombo, GiaCombo, MoTa, HinhAnh, TrangThai) VALUES
(1, N'Combo Solo 1 Người', 69000, N'1 Bắp rang bơ nhỏ + 1 Pepsi lớn mát lạnh', 'combo-solo.jpg', N'Đang bán'),
(2, N'Combo Couple 2 Người', 99000, N'1 Bắp lớn tự chọn vị + 2 Pepsi lớn', 'combo-couple.jpg', N'Đang bán'),
(3, N'Combo Family Gia Đình', 149000, N'2 Bắp lớn + 3 Nước ngọt lớn + 1 Gói Snack', 'combo-family.jpg', N'Đang bán'),
(4, N'Combo Siêu Tiết Kiệm', 79000, N'1 Bắp Phô Mai thơm béo + 1 Trà Đào Cam Sả thanh mát', 'combo-sweet.jpg', N'Đang bán');
SET IDENTITY_INSERT Combo OFF;
GO

-- CHI TIẾT SẢN PHẨM BÊN TRONG TỪNG GÓI COMBO
INSERT INTO ChiTietCombo (MaCombo, MaSP, SoLuong, GhiChu) VALUES
(1, 1, 1, N'Bắp vị bơ ngọt ngào'),
(1, 4, 1, N'Pepsi mát lạnh'),
(2, 2, 1, N'Bắp phô mai đặc biệt size L'),
(2, 4, 2, N'2 ly Pepsi tươi size L'),
(3, 1, 2, N'2 hộp bắp size L'),
(3, 4, 3, N'3 ly nước ngọt tuỳ chọn'),
(3, 8, 1, N'1 gói Snack Lays'),
(4, 2, 1, N'1 hộp bắp vị phô mai'),
(4, 6, 1, N'1 ly trà đào cam sả');
GO

-- TẠO CÁC SUẤT CHIẾU MẪU ĐẦY ĐỦ CÁC KHUNG GIỜ HÔM NAY VÀ NHỮNG NGÀY TỚI
DECLARE @today DATE = CAST(GETDATE() AS DATE);
DECLARE @tom DATE = DATEADD(DAY, 1, @today);
DECLARE @nxt DATE = DATEADD(DAY, 2, @today);

SET IDENTITY_INSERT SuatChieu ON;
INSERT INTO SuatChieu (MaSuat, MaPhim, MaPhong, DinhDang, NgayChieu, GioBatDau, GioKetThuc, GiaVeCoBan, TrangThai, LyDoHuy) VALUES
(1, 1, 1, N'2D', @today, '09:00:00', '10:55:00', 75000, N'Đang mở bán', NULL),
(2, 1, 1, N'2D', @today, '14:30:00', '16:25:00', 80000, N'Đang mở bán', NULL),
(3, 2, 1, N'2D', @today, '19:00:00', '21:26:00', 85000, N'Đang mở bán', NULL),
(4, 4, 2, N'3D', @today, '10:00:00', '12:10:00', 100000, N'Đang mở bán', NULL),
(5, 5, 2, N'3D', @today, '15:00:00', '17:29:00', 105000, N'Đang mở bán', NULL),
(6, 6, 3, N'IMAX Laser', @today, '13:00:00', '16:01:00', 130000, N'Đang mở bán', NULL),
(7, 6, 3, N'IMAX Laser', @today, '19:30:00', '22:31:00', 140000, N'Đang mở bán', NULL),
(8, 3, 1, @tom, '09:30:00', '11:19:00', 75000, N'Đang mở bán', NULL),
(9, 4, 2, N'3D', @tom, '14:00:00', '16:10:00', 100000, N'Đang mở bán', NULL),
(10, 2, 1, @nxt, '19:30:00', '21:56:00', 85000, N'Đang mở bán', NULL);
SET IDENTITY_INSERT SuatChieu OFF;
GO

-- TẠO MỘT SỐ HÓA ĐƠN & VÉ MẪU ĐỂ MÀN HÌNH QUẢN LÝ HÓA ĐƠN VÀ THỐNG KÊ DOANH THU CÓ DỮ LIỆU
SET IDENTITY_INSERT HoaDon ON;
INSERT INTO HoaDon (MaDatVe, MaTK, MaKH, MaKM, NgayDat, TongTien, TienGiam, TrangThai) VALUES
(1, 2, 'KH001', NULL, DATEADD(HOUR, -5, GETDATE()), 194000, 0, N'Đã hoàn tất'),
(2, 2, 'KH003', NULL, DATEADD(HOUR, -3, GETDATE()), 184000, 10000, N'Đã hoàn tất'),
(3, 3, NULL, NULL, DATEADD(MINUTE, -40, GETDATE()), 95000, 0, N'Chờ thanh toán');
SET IDENTITY_INSERT HoaDon OFF;
GO

-- VÉ ĐƯỢC BÁN THEO HÓA ĐƠN
SET IDENTITY_INSERT Ve ON;
INSERT INTO Ve (MaVe, MaDatVe, MaSuat, MaGhe, GiaVe, MaQR, TrangThai) VALUES
-- Hóa đơn 1: 1 Ghế VIP (D6 - 95.000đ) trong suất 2 + 1 Combo Couple (99.000đ) = 194.000đ
(1, 1, 2, 42, 95000, 'TICKET-SC2-G42-88231', N'Đã bán'),
-- Hóa đơn 2: 1 Ghế Thường (A5 - 75.000đ) + 1 Ghế Thường (A6 - 75.000đ) = 150.000đ + Combo Solo (69.000đ) - 25.000đ = 194.000đ (giảm 10k -> 184k)
(2, 2, 1, 5, 75000, 'TICKET-SC1-G5-99214', N'Đã bán'),
(3, 2, 1, 6, 75000, 'TICKET-SC1-G6-99215', N'Đã bán'),
-- Hóa đơn 3: 1 Ghế VIP (D5 - 95.000đ) chờ thanh toán
(4, 3, 2, 41, 95000, 'TICKET-SC2-G41-11029', N'Chờ thanh toán');
SET IDENTITY_INSERT Ve OFF;
GO

-- CHI TIẾT COMBO BẮP NƯỚC KÈM THEO
SET IDENTITY_INSERT ChiTietHoaDon ON;
INSERT INTO ChiTietHoaDon (MaChiTiet, MaDatVe, MaSP, MaCombo, SoLuong, DonGia) VALUES
(1, 1, NULL, 2, 1, 99000),
(2, 2, NULL, 1, 1, 69000);
SET IDENTITY_INSERT ChiTietHoaDon OFF;
GO

-- LỊCH SỬ THANH TOÁN
SET IDENTITY_INSERT ThanhToan ON;
INSERT INTO ThanhToan (MaThanhToan, MaDatVe, PhuongThuc, NgayThanhToan, TrangThai) VALUES
(1, 1, N'Tiền mặt', DATEADD(HOUR, -5, GETDATE()), N'Thành công'),
(2, 2, N'Chuyển khoản QR', DATEADD(HOUR, -3, GETDATE()), N'Thành công'),
(3, 3, N'Tiền mặt', DATEADD(MINUTE, -40, GETDATE()), N'Đang xử lý');
SET IDENTITY_INSERT ThanhToan OFF;
GO

-- ============================================================================
-- KIỂM TRA TỔNG QUAN DỮ LIỆU ĐÃ NẠP
-- ============================================================================
PRINT N'====================================================================';
PRINT N'==> CHÚC MỪNG: KHỞI TẠO CSDL CINEMAX THÀNH CÔNG 100%!';
PRINT N'====================================================================';
SELECT 'TaiKhoan' AS TenBang, COUNT(*) AS SoBanGhi FROM TaiKhoan UNION ALL
SELECT 'KhachHang', COUNT(*) FROM KhachHang UNION ALL
SELECT 'TheLoai', COUNT(*) FROM TheLoai UNION ALL
SELECT 'Phim', COUNT(*) FROM Phim UNION ALL
SELECT 'Phim_TheLoai', COUNT(*) FROM Phim_TheLoai UNION ALL
SELECT 'LoaiPhong', COUNT(*) FROM LoaiPhong UNION ALL
SELECT 'PhongChieu', COUNT(*) FROM PhongChieu UNION ALL
SELECT 'LoaiGhe', COUNT(*) FROM LoaiGhe UNION ALL
SELECT 'Ghe', COUNT(*) FROM Ghe UNION ALL
SELECT 'SuatChieu', COUNT(*) FROM SuatChieu UNION ALL
SELECT 'SanPham', COUNT(*) FROM SanPham UNION ALL
SELECT 'Combo', COUNT(*) FROM Combo UNION ALL
SELECT 'ChiTietCombo', COUNT(*) FROM ChiTietCombo UNION ALL
SELECT 'HoaDon', COUNT(*) FROM HoaDon UNION ALL
SELECT 'Ve', COUNT(*) FROM Ve UNION ALL
SELECT 'ChiTietHoaDon', COUNT(*) FROM ChiTietHoaDon UNION ALL
SELECT 'ThanhToan', COUNT(*) FROM ThanhToan;
GO
