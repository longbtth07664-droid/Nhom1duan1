-- [ANH-CSDL] Chạy một lần trên cùng database ứng dụng đang kết nối.
-- Chỉ thêm cột ảnh sản phẩm. Tên ảnh combo tiếp tục dùng Combo.HinhAnh.
IF OBJECT_ID(N'dbo.SanPham', N'U') IS NULL
    THROW 50001, N'Không tìm thấy bảng dbo.SanPham. Hãy chọn database của dự án.', 1;

IF COL_LENGTH(N'dbo.SanPham', N'HinhAnh') IS NULL
    ALTER TABLE dbo.SanPham ADD HinhAnh NVARCHAR(255) NULL;
