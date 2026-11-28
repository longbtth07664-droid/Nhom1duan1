package repository;

import entity.ChiTietHoaDon;
import entity.HoaDon;
import entity.KhachHang;
import entity.Ve;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

public class HoaDonRepository {

    private static final String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=QuanLyDatVeRapPhim;encrypt=true;trustServerCertificate=true;";
    private static final String DB_USER = "sa";
    private static final String DB_PASS = "123";

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }

    private boolean checkColumnExists(Connection conn, String tableName, String columnName) {
        try {
            DatabaseMetaData meta = conn.getMetaData();
            try (ResultSet rs = meta.getColumns(null, null, tableName, columnName)) {
                return rs.next();
            }
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Lấy danh sách hóa đơn kèm lọc từ khóa, khoảng ngày, phương thức thanh toán và trạng thái
     */
    public List<HoaDon> getAll(String keyword, String fromDate, String toDate, String phuongThuc) {
        return getAll(keyword, fromDate, toDate, phuongThuc, null);
    }

    public List<HoaDon> getAll(String keyword, String fromDate, String toDate, String phuongThuc, String trangThai) {
        List<HoaDon> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT h.MaDatVe, h.MaTK, h.NgayDat, h.TongTien, h.TrangThai, ");
        sql.append("tk.HoTen AS TenThuNgan, ");
        sql.append("tt.PhuongThuc AS PhuongThucTT ");
        sql.append("FROM HoaDon h ");
        sql.append("LEFT JOIN TaiKhoan tk ON h.MaTK = tk.MaTK ");
        sql.append("LEFT JOIN ( ");
        sql.append("    SELECT MaDatVe, MAX(PhuongThuc) AS PhuongThuc ");
        sql.append("    FROM ThanhToan ");
        sql.append("    GROUP BY MaDatVe ");
        sql.append(") tt ON h.MaDatVe = tt.MaDatVe ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = "%" + keyword.trim() + "%";
            sql.append("AND (CAST(h.MaDatVe AS VARCHAR) LIKE ? OR tk.HoTen LIKE ?) ");
            params.add(kw);
            params.add(kw);
        }

        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append("AND h.NgayDat >= ? ");
            params.add(fromDate.trim() + " 00:00:00");
        }

        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append("AND h.NgayDat <= ? ");
            params.add(toDate.trim() + " 23:59:59");
        }

        if (phuongThuc != null && !phuongThuc.trim().isEmpty() && !"Tất cả".equalsIgnoreCase(phuongThuc.trim())) {
            sql.append("AND tt.PhuongThuc = ? ");
            params.add(phuongThuc.trim());
        }

        if (trangThai != null && !trangThai.trim().isEmpty() && !"Tất cả".equalsIgnoreCase(trangThai.trim())) {
            sql.append("AND h.TrangThai = ? ");
            params.add(trangThai.trim());
        }

        sql.append("ORDER BY h.NgayDat DESC, h.MaDatVe DESC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HoaDon hd = new HoaDon();
                    hd.setMaDatVe(rs.getInt("MaDatVe"));
                    hd.setMaTK(rs.getInt("MaTK"));
                    Timestamp ts = rs.getTimestamp("NgayDat");
                    if (ts != null) {
                        hd.setNgayDat(ts.toLocalDateTime());
                    }
                    hd.setTongTien(rs.getBigDecimal("TongTien"));
                    hd.setTrangThai(rs.getString("TrangThai"));
                    hd.setTenThuNgan(rs.getString("TenThuNgan"));
                    String pt = rs.getString("PhuongThucTT");
                    hd.setPhuongThuc(pt != null ? pt : "Tiền mặt");
                    list.add(hd);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy thông tin chi tiết đầy đủ của 1 hóa đơn (bao gồm danh sách vé & combo)
     */
    public HoaDon getById(int maDatVe) {
        HoaDon hd = null;
        String sqlHd = "SELECT h.MaDatVe, h.MaTK, h.NgayDat, h.TongTien, h.TienGiam, h.TrangThai, " +
                "tk.HoTen AS TenThuNgan, " +
                "tt.PhuongThuc AS PhuongThucTT " +
                "FROM HoaDon h " +
                "LEFT JOIN TaiKhoan tk ON h.MaTK = tk.MaTK " +
                "LEFT JOIN (SELECT MaDatVe, MAX(PhuongThuc) AS PhuongThuc FROM ThanhToan GROUP BY MaDatVe) tt ON h.MaDatVe = tt.MaDatVe " +
                "WHERE h.MaDatVe = ?";

        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlHd)) {
                ps.setInt(1, maDatVe);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        hd = new HoaDon();
                        hd.setMaDatVe(rs.getInt("MaDatVe"));
                        hd.setMaTK(rs.getInt("MaTK"));
                        Timestamp ts = rs.getTimestamp("NgayDat");
                        if (ts != null) {
                            hd.setNgayDat(ts.toLocalDateTime());
                        }
                        hd.setTongTien(rs.getBigDecimal("TongTien"));
                        hd.setTienGiam(rs.getBigDecimal("TienGiam"));
                        hd.setTrangThai(rs.getString("TrangThai"));
                        hd.setTenThuNgan(rs.getString("TenThuNgan"));
                        String pt = rs.getString("PhuongThucTT");
                        hd.setPhuongThuc(pt != null ? pt : "Tiền mặt");
                    }
                }
            }

            if (hd == null) return null;

            // Lấy danh sách Vé
            String sqlVe = "SELECT v.MaVe, v.MaDatVe, v.MaSuat, v.MaGhe, v.GiaVe, v.MaQR, v.TrangThai, " +
                    "g.HangGhe, g.SoGhe, " +
                    "p.TenPhim, pc.TenPhong, sc.NgayChieu, sc.GioBatDau " +
                    "FROM Ve v " +
                    "LEFT JOIN Ghe g ON v.MaGhe = g.MaGhe " +
                    "LEFT JOIN SuatChieu sc ON v.MaSuat = sc.MaSuat " +
                    "LEFT JOIN Phim p ON sc.MaPhim = p.MaPhim " +
                    "LEFT JOIN PhongChieu pc ON sc.MaPhong = pc.MaPhong " +
                    "WHERE v.MaDatVe = ?";

            try (PreparedStatement ps = conn.prepareStatement(sqlVe)) {
                ps.setInt(1, maDatVe);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Ve ve = new Ve();
                        ve.setMaVe(rs.getInt("MaVe"));
                        ve.setMaDatVe(rs.getInt("MaDatVe"));
                        ve.setMaSuat(rs.getInt("MaSuat"));
                        ve.setMaGhe(rs.getInt("MaGhe"));
                        ve.setGiaVe(rs.getBigDecimal("GiaVe"));
                        ve.setMaQR(rs.getString("MaQR"));
                        ve.setTrangThai(rs.getString("TrangThai"));

                        String hang = rs.getString("HangGhe");
                        int so = rs.getInt("SoGhe");
                        ve.setTenGhe((hang != null ? hang : "") + (so > 0 ? so : ""));
                        ve.setTenPhim(rs.getString("TenPhim"));
                        ve.setTenPhong(rs.getString("TenPhong"));

                        java.sql.Date d = rs.getDate("NgayChieu");
                        if (d != null) ve.setNgayChieu(d.toString());

                        Time t = rs.getTime("GioBatDau");
                        if (t != null) ve.setGioChieu(t.toString().substring(0, 5));

                        hd.getDanhSachVe().add(ve);
                    }
                }
            }

            // Lấy danh sách Combo / Sản phẩm lẻ (ChiTietHoaDon)
            boolean hasMaSPCol = checkColumnExists(conn, "ChiTietHoaDon", "MaSP");
            String sqlCombo;
            if (hasMaSPCol) {
                sqlCombo = "SELECT ct.MaChiTiet, ct.MaDatVe, ct.MaCombo, ct.MaSP, ct.SoLuong, ct.DonGia, " +
                        "COALESCE(cb.TenCombo, sp.TenSP, N'Sản phẩm F&B') AS TenCombo " +
                        "FROM ChiTietHoaDon ct " +
                        "LEFT JOIN Combo cb ON ct.MaCombo = cb.MaCombo " +
                        "LEFT JOIN SanPham sp ON ct.MaSP = sp.MaSP " +
                        "WHERE ct.MaDatVe = ?";
            } else {
                sqlCombo = "SELECT ct.MaChiTiet, ct.MaDatVe, ct.MaCombo, ct.SoLuong, ct.DonGia, " +
                        "cb.TenCombo " +
                        "FROM ChiTietHoaDon ct " +
                        "LEFT JOIN Combo cb ON ct.MaCombo = cb.MaCombo " +
                        "WHERE ct.MaDatVe = ?";
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlCombo)) {
                ps.setInt(1, maDatVe);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        ChiTietHoaDon ct = new ChiTietHoaDon();
                        ct.setMaChiTiet(rs.getInt("MaChiTiet"));
                        ct.setMaDatVe(rs.getInt("MaDatVe"));
                        ct.setMaCombo(rs.getInt("MaCombo"));
                        if (hasMaSPCol) {
                            Object spObj = rs.getObject("MaSP");
                            if (spObj != null) ct.setMaSP(((Number) spObj).intValue());
                        }
                        ct.setSoLuong(rs.getInt("SoLuong"));
                        ct.setDonGia(rs.getBigDecimal("DonGia"));
                        ct.setTenCombo(rs.getString("TenCombo"));
                        hd.getDanhSachChiTiet().add(ct);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return hd;
    }

    /**
     * Tạo hóa đơn, vé, chi tiết combo và bản ghi thanh toán trong 1 transaction an toàn
     */
    public int taoHoaDonThanhToan(int maTK, String maKH, BigDecimal tongTien, BigDecimal tienGiam,
                                  String phuongThuc, List<Ve> listVe, List<ChiTietHoaDon> listCombo) {
        return taoHoaDonThanhToan(maTK, maKH, null, tongTien, tienGiam, phuongThuc, listVe, listCombo, false);
    }

    public int taoHoaDonThanhToan(int maTK, String maKH, BigDecimal tongTien, BigDecimal tienGiam,
                                  String phuongThuc, List<Ve> listVe, List<ChiTietHoaDon> listCombo, boolean isPending) {
        return taoHoaDonThanhToan(maTK, maKH, null, tongTien, tienGiam, phuongThuc, listVe, listCombo, isPending);
    }

    /**
     * Tạo hóa đơn với tùy chọn Lưu tạm (Chờ thanh toán) hoặc Hoàn tất ngay, hỗ trợ lưu Mã Khuyến Mãi (MaKM)
     */
    public int taoHoaDonThanhToan(int maTK, String maKH, Integer maKM, BigDecimal tongTien, BigDecimal tienGiam,
                                  String phuongThuc, List<Ve> listVe, List<ChiTietHoaDon> listCombo, boolean isPending) {
        Connection conn = null;
        int generatedMaDatVe = -1;

        String trangThaiHD = isPending ? "Chờ thanh toán" : "Đã hoàn tất";
        String trangThaiVe = isPending ? "Chờ thanh toán" : "Đã bán";
        String trangThaiTT = isPending ? "Chờ xử lý" : "Thành công";

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            boolean hasMaKH = checkColumnExists(conn, "HoaDon", "MaKH");
            boolean hasTienGiam = checkColumnExists(conn, "HoaDon", "TienGiam");
            boolean hasMaKM = checkColumnExists(conn, "HoaDon", "MaKM");

            // 1. Insert vào HoaDon
            StringBuilder insertHd = new StringBuilder("INSERT INTO HoaDon (MaTK, NgayDat, TongTien");
            if (hasTienGiam) insertHd.append(", TienGiam");
            if (hasMaKH && maKH != null && !maKH.trim().isEmpty()) insertHd.append(", MaKH");
            if (hasMaKM && maKM != null && maKM > 0) insertHd.append(", MaKM");
            insertHd.append(", TrangThai) VALUES (?, ?, ?");
            if (hasTienGiam) insertHd.append(", ?");
            if (hasMaKH && maKH != null && !maKH.trim().isEmpty()) insertHd.append(", ?");
            if (hasMaKM && maKM != null && maKM > 0) insertHd.append(", ?");
            insertHd.append(", ?)");

            try (PreparedStatement psHd = conn.prepareStatement(insertHd.toString(), Statement.RETURN_GENERATED_KEYS)) {
                int col = 1;
                psHd.setInt(col++, maTK > 0 ? maTK : 1);
                psHd.setTimestamp(col++, new Timestamp(System.currentTimeMillis()));
                psHd.setBigDecimal(col++, tongTien != null ? tongTien : BigDecimal.ZERO);
                if (hasTienGiam) {
                    psHd.setBigDecimal(col++, tienGiam != null ? tienGiam : BigDecimal.ZERO);
                }
                if (hasMaKH && maKH != null && !maKH.trim().isEmpty()) {
                    psHd.setString(col++, maKH.trim());
                }
                if (hasMaKM && maKM != null && maKM > 0) {
                    psHd.setInt(col++, maKM);
                }
                psHd.setString(col++, trangThaiHD);

                psHd.executeUpdate();
                try (ResultSet rsKeys = psHd.getGeneratedKeys()) {
                    if (rsKeys.next()) {
                        generatedMaDatVe = rsKeys.getInt(1);
                    }
                }
            }

            if (generatedMaDatVe <= 0) {
                conn.rollback();
                return -1;
            }

            // 2. Insert hoặc Update danh sách Vé (tránh trùng khóa UQ_Suat_Ghe khi test lại ghế đã chọn)
            if (listVe != null && !listVe.isEmpty()) {
                String sqlUpsertVe = "IF EXISTS (SELECT 1 FROM Ve WHERE MaSuat = ? AND MaGhe = ?) " +
                        "UPDATE Ve SET MaDatVe = ?, GiaVe = ?, MaQR = ?, TrangThai = ? WHERE MaSuat = ? AND MaGhe = ? " +
                        "ELSE " +
                        "INSERT INTO Ve (MaDatVe, MaSuat, MaGhe, GiaVe, MaQR, TrangThai) VALUES (?, ?, ?, ?, ?, ?)";
                try (PreparedStatement psVe = conn.prepareStatement(sqlUpsertVe)) {
                    for (Ve v : listVe) {
                        int mSuat = v.getMaSuat() != null ? v.getMaSuat() : 1;
                        int mGhe = v.getMaGhe() != null ? v.getMaGhe() : 1;
                        BigDecimal gVe = v.getGiaVe() != null ? v.getGiaVe() : BigDecimal.ZERO;

                        String qrCode = v.getMaQR();
                        if (qrCode == null || qrCode.trim().isEmpty()) {
                            qrCode = "CINEMAX-HD" + generatedMaDatVe + "-S" + mSuat + "-G" + mGhe + "-" +
                                    UUID.randomUUID().toString().substring(0, 8).toUpperCase();
                        }

                        // 1, 2: IF EXISTS
                        psVe.setInt(1, mSuat);
                        psVe.setInt(2, mGhe);
                        // 3, 4, 5, 6: UPDATE (MaDatVe, GiaVe, MaQR, TrangThai)
                        psVe.setInt(3, generatedMaDatVe);
                        psVe.setBigDecimal(4, gVe);
                        psVe.setString(5, qrCode);
                        psVe.setString(6, trangThaiVe);
                        // 7, 8: WHERE MaSuat = ?, MaGhe = ?
                        psVe.setInt(7, mSuat);
                        psVe.setInt(8, mGhe);
                        // 9, 10, 11, 12, 13, 14: INSERT (MaDatVe, MaSuat, MaGhe, GiaVe, MaQR, TrangThai)
                        psVe.setInt(9, generatedMaDatVe);
                        psVe.setInt(10, mSuat);
                        psVe.setInt(11, mGhe);
                        psVe.setBigDecimal(12, gVe);
                        psVe.setString(13, qrCode);
                        psVe.setString(14, trangThaiVe);

                        psVe.executeUpdate();
                    }
                }
            }

            // 3. Insert danh sách ChiTietHoaDon (Gói Combo & Sản phẩm bán lẻ)
            if (listCombo != null && !listCombo.isEmpty()) {
                boolean hasMaSPCol = checkColumnExists(conn, "ChiTietHoaDon", "MaSP");
                String sqlCombo;
                if (hasMaSPCol) {
                    sqlCombo = "INSERT INTO ChiTietHoaDon (MaDatVe, MaSP, MaCombo, SoLuong, DonGia) VALUES (?, ?, ?, ?, ?)";
                } else {
                    sqlCombo = "INSERT INTO ChiTietHoaDon (MaDatVe, MaCombo, SoLuong, DonGia) VALUES (?, ?, ?, ?)";
                }

                try (PreparedStatement psCombo = conn.prepareStatement(sqlCombo)) {
                    for (ChiTietHoaDon ct : listCombo) {
                        if (ct.getSoLuong() == null || ct.getSoLuong() <= 0) continue;
                        if (ct.getMaCombo() == null && ct.getMaSP() == null) continue;

                        if (hasMaSPCol) {
                            psCombo.setInt(1, generatedMaDatVe);
                            if (ct.getMaSP() != null && ct.getMaSP() > 0) {
                                psCombo.setInt(2, ct.getMaSP());
                            } else {
                                psCombo.setNull(2, java.sql.Types.INTEGER);
                            }
                            if (ct.getMaCombo() != null && ct.getMaCombo() > 0) {
                                psCombo.setInt(3, ct.getMaCombo());
                            } else {
                                psCombo.setNull(3, java.sql.Types.INTEGER);
                            }
                            psCombo.setInt(4, ct.getSoLuong());
                            psCombo.setBigDecimal(5, ct.getDonGia() != null ? ct.getDonGia() : BigDecimal.ZERO);
                        } else {
                            psCombo.setInt(1, generatedMaDatVe);
                            psCombo.setInt(2, ct.getMaCombo() != null ? ct.getMaCombo() : 1);
                            psCombo.setInt(3, ct.getSoLuong());
                            psCombo.setBigDecimal(4, ct.getDonGia() != null ? ct.getDonGia() : BigDecimal.ZERO);
                        }
                        psCombo.addBatch();
                    }
                    psCombo.executeBatch();
                }
            }

            // 4. Insert vào ThanhToan
            String sqlTT = "INSERT INTO ThanhToan (MaDatVe, PhuongThuc, NgayThanhToan, TrangThai) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psTT = conn.prepareStatement(sqlTT)) {
                psTT.setInt(1, generatedMaDatVe);
                psTT.setString(2, (phuongThuc != null && !phuongThuc.trim().isEmpty()) ? phuongThuc.trim() : "Tiền mặt");
                psTT.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
                psTT.setString(4, trangThaiTT);
                psTT.executeUpdate();
            }

            // 5. Cập nhật điểm tích lũy Khách hàng (chỉ khi hoàn tất thanh toán)
            if (!isPending && maKH != null && !maKH.trim().isEmpty()) {
                try {
                    int diemCong = (tongTien != null) ? tongTien.intValue() / 10000 : 0;
                    int diemTru = (tienGiam != null) ? tienGiam.intValue() / 1000 : 0;
                    int delta = diemCong - diemTru;

                    String sqlKh = "UPDATE KhachHang SET DiemTichLuy = CASE WHEN DiemTichLuy + ? < 0 THEN 0 ELSE DiemTichLuy + ? END WHERE MaKH = ?";
                    try (PreparedStatement psKh = conn.prepareStatement(sqlKh)) {
                        psKh.setInt(1, delta);
                        psKh.setInt(2, delta);
                        psKh.setString(3, maKH.trim());
                        psKh.executeUpdate();
                    }
                } catch (Exception ex) {
                    System.err.println("Bỏ qua lỗi cập nhật điểm KH: " + ex.getMessage());
                }
            }

            conn.commit();
            return generatedMaDatVe;

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {}
            }
            return -1;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Thống kê tổng hợp doanh thu và số lượng đơn hàng
     */
    public Map<String, Object> getThongKe() {
        Map<String, Object> map = new HashMap<>();
        BigDecimal tongDoanhThu = BigDecimal.ZERO;
        BigDecimal doanhThuHomNay = BigDecimal.ZERO;
        int tongHoaDon = 0;
        int hoaDonHomNay = 0;

        String sqlTong = "SELECT COUNT(*) AS TongHD, SUM(TongTien) AS TongTien FROM HoaDon WHERE TrangThai IS NULL OR TrangThai <> N'Đã hủy'";
        String sqlToday = "SELECT COUNT(*) AS HDToday, SUM(TongTien) AS TienToday FROM HoaDon " +
                "WHERE (TrangThai IS NULL OR TrangThai <> N'Đã hủy') " +
                "AND CONVERT(date, NgayDat) = CONVERT(date, GETDATE())";

        try (Connection conn = getConnection()) {
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(sqlTong)) {
                if (rs.next()) {
                    tongHoaDon = rs.getInt("TongHD");
                    BigDecimal bd = rs.getBigDecimal("TongTien");
                    if (bd != null) tongDoanhThu = bd;
                }
            }

            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(sqlToday)) {
                if (rs.next()) {
                    hoaDonHomNay = rs.getInt("HDToday");
                    BigDecimal bd = rs.getBigDecimal("TienToday");
                    if (bd != null) doanhThuHomNay = bd;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        map.put("tongDoanhThu", tongDoanhThu);
        map.put("doanhThuHomNay", doanhThuHomNay);
        map.put("tongHoaDon", tongHoaDon);
        map.put("hoaDonHomNay", hoaDonHomNay);
        return map;
    }

    /**
     * Tìm khách hàng theo Số điện thoại hoặc Mã KH
     */
    public KhachHang timKhachHangTheoSDT(String sdt) {
        if (sdt == null || sdt.trim().isEmpty()) return null;
        try (Connection conn = getConnection()) {
            boolean hasNgaySinh = checkColumnExists(conn, "KhachHang", "NgaySinh");
            String sql = hasNgaySinh
                    ? "SELECT MaKH, HoTen, SDT, DiemTichLuy, GioiTinh, NgaySinh FROM KhachHang WHERE SDT = ? OR MaKH = ?"
                    : "SELECT MaKH, HoTen, SDT, DiemTichLuy, GioiTinh FROM KhachHang WHERE SDT = ? OR MaKH = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, sdt.trim());
                ps.setString(2, sdt.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        KhachHang kh = new KhachHang();
                        kh.setMaKH(rs.getString("MaKH"));
                        kh.setHoTen(rs.getString("HoTen"));
                        kh.setSdt(rs.getString("SDT"));
                        kh.setDiemTichLuy(rs.getInt("DiemTichLuy"));
                        kh.setGioiTinh(rs.getString("GioiTinh"));
                        if (hasNgaySinh) {
                            java.sql.Date ns = rs.getDate("NgaySinh");
                            if (ns != null) kh.setNgaySinh(ns.toLocalDate());
                        }
                        return kh;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tạo nhanh khách hàng mới nếu chưa có trong hệ thống khi thanh toán
     */
    public KhachHang taoKhachHangNhanh(String hoTen, String sdt) {
        if (sdt == null || sdt.trim().isEmpty()) return null;
        KhachHang existing = timKhachHangTheoSDT(sdt);
        if (existing != null) return existing;

        String newMaKH = "KH" + System.currentTimeMillis() % 100000;
        String sql = "INSERT INTO KhachHang (MaKH, HoTen, SDT, DiemTichLuy, GioiTinh) VALUES (?, ?, ?, 0, N'Khác')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newMaKH);
            ps.setString(2, (hoTen != null && !hoTen.trim().isEmpty()) ? hoTen.trim() : "Khách hàng " + sdt);
            ps.setString(3, sdt.trim());
            ps.executeUpdate();

            KhachHang kh = new KhachHang();
            kh.setMaKH(newMaKH);
            kh.setHoTen(hoTen);
            kh.setSdt(sdt);
            kh.setDiemTichLuy(0);
            return kh;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Hoàn tất thanh toán cho hóa đơn đang "Chờ thanh toán"
     */
    public boolean hoanTatThanhToan(int maDatVe, String phuongThuc) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // 1. Cập nhật trạng thái Hóa đơn -> "Đã hoàn tất"
            String sqlHd = "UPDATE HoaDon SET TrangThai = N'Đã hoàn tất' WHERE MaDatVe = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlHd)) {
                ps.setInt(1, maDatVe);
                ps.executeUpdate();
            }

            // 2. Cập nhật trạng thái Vé -> "Đã bán"
            String sqlVe = "UPDATE Ve SET TrangThai = N'Đã bán' WHERE MaDatVe = ? AND (TrangThai = N'Chờ thanh toán' OR TrangThai IS NULL)";
            try (PreparedStatement ps = conn.prepareStatement(sqlVe)) {
                ps.setInt(1, maDatVe);
                ps.executeUpdate();
            }

            // 3. Cập nhật ThanhToan -> "Thành công" và phương thức
            String sqlTT = "UPDATE ThanhToan SET TrangThai = N'Thành công', PhuongThuc = ?, NgayThanhToan = GETDATE() WHERE MaDatVe = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlTT)) {
                ps.setString(1, (phuongThuc != null && !phuongThuc.trim().isEmpty()) ? phuongThuc.trim() : "Tiền mặt");
                ps.setInt(2, maDatVe);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    String sqlInsertTT = "INSERT INTO ThanhToan (MaDatVe, PhuongThuc, NgayThanhToan, TrangThai) VALUES (?, ?, GETDATE(), N'Thành công')";
                    try (PreparedStatement psIns = conn.prepareStatement(sqlInsertTT)) {
                        psIns.setInt(1, maDatVe);
                        psIns.setString(2, (phuongThuc != null && !phuongThuc.trim().isEmpty()) ? phuongThuc.trim() : "Tiền mặt");
                        psIns.executeUpdate();
                    }
                }
            }

            // 4. Cộng điểm tích lũy cho khách hàng (nếu có MaKH)
            try {
                String sqlGetKh = "SELECT MaKH, TongTien, TienGiam FROM HoaDon WHERE MaDatVe = ?";
                try (PreparedStatement psGet = conn.prepareStatement(sqlGetKh)) {
                    psGet.setInt(1, maDatVe);
                    try (ResultSet rs = psGet.executeQuery()) {
                        if (rs.next()) {
                            String maKh = rs.getString("MaKH");
                            BigDecimal tongTien = rs.getBigDecimal("TongTien");
                            BigDecimal tienGiam = rs.getBigDecimal("TienGiam");
                            if (maKh != null && !maKh.trim().isEmpty()) {
                                int diemCong = (tongTien != null) ? tongTien.intValue() / 10000 : 0;
                                int diemTru = (tienGiam != null) ? tienGiam.intValue() / 1000 : 0;
                                int delta = diemCong - diemTru;
                                String sqlKh = "UPDATE KhachHang SET DiemTichLuy = CASE WHEN DiemTichLuy + ? < 0 THEN 0 ELSE DiemTichLuy + ? END WHERE MaKH = ?";
                                try (PreparedStatement psKh = conn.prepareStatement(sqlKh)) {
                                    psKh.setInt(1, delta);
                                    psKh.setInt(2, delta);
                                    psKh.setString(3, maKh.trim());
                                    psKh.executeUpdate();
                                }
                            }
                        }
                    }
                }
            } catch (Exception ex) {
                System.err.println("Bỏ qua lỗi cộng điểm KH khi thu tiền: " + ex.getMessage());
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Hủy hóa đơn và nhả ghế lại cho phòng chiếu
     */
    public boolean huyHoaDon(int maDatVe) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String sqlHd = "UPDATE HoaDon SET TrangThai = N'Đã hủy' WHERE MaDatVe = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlHd)) {
                ps.setInt(1, maDatVe);
                ps.executeUpdate();
            }

            String sqlVe = "UPDATE Ve SET TrangThai = N'Đã hủy' WHERE MaDatVe = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlVe)) {
                ps.setInt(1, maDatVe);
                ps.executeUpdate();
            }

            String sqlTT = "UPDATE ThanhToan SET TrangThai = N'Đã hủy' WHERE MaDatVe = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlTT)) {
                ps.setInt(1, maDatVe);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Soát vé (Check-in) theo mã QR hoặc mã vé (mặc định không cưỡng chế)
     */
    public Map<String, Object> kiemTraVaCheckInVe(String code) {
        return kiemTraVaCheckInVe(code, false);
    }

    /**
     * Soát vé (Check-in) thông minh:
     * - Kiểm tra mã QR / Barcode / Mã Vé / Mã Hóa Đơn
     * - Kiểm tra trạng thái thanh toán và hủy vé
     * - Kiểm tra chống gian lận (vé đã check-in trước đó)
     * - Kiểm tra thời gian suất chiếu (ngày chiếu, khung giờ mở cửa trước 45 phút)
     * - Hỗ trợ đặc cách cho vào (forceCheckIn = true)
     */
    public Map<String, Object> kiemTraVaCheckInVe(String code, boolean forceCheckIn) {
        Map<String, Object> result = new HashMap<>();
        if (code == null || code.trim().isEmpty()) {
            result.put("success", false);
            result.put("statusCode", "INVALID_INPUT");
            result.put("message", "Vui lòng nhập hoặc quét mã vé / mã vạch / mã QR!");
            return result;
        }

        String cleanCode = code.trim();
        // Chuẩn hóa nếu quét dạng #VE12, VE12, #HD12, HD12
        String codeWithoutHash = cleanCode.startsWith("#") ? cleanCode.substring(1) : cleanCode;
        String numberOnly = codeWithoutHash.replaceAll("[^0-9]", "");

        String sql = "SELECT v.MaVe, v.MaDatVe, v.MaSuat, v.MaGhe, v.GiaVe, v.MaQR, v.TrangThai AS TrangThaiVe, " +
                "g.HangGhe, g.SoGhe, " +
                "p.TenPhim, pc.TenPhong, sc.NgayChieu, sc.GioBatDau, " +
                "hd.TrangThai AS TrangThaiHD, hd.TongTien " +
                "FROM Ve v " +
                "LEFT JOIN Ghe g ON v.MaGhe = g.MaGhe " +
                "LEFT JOIN SuatChieu sc ON v.MaSuat = sc.MaSuat " +
                "LEFT JOIN Phim p ON sc.MaPhim = p.MaPhim " +
                "LEFT JOIN PhongChieu pc ON sc.MaPhong = pc.MaPhong " +
                "LEFT JOIN HoaDon hd ON v.MaDatVe = hd.MaDatVe " +
                "WHERE v.MaQR = ? " +
                "OR CAST(v.MaVe AS VARCHAR) = ? " +
                "OR v.MaQR LIKE ? " +
                (numberOnly.isEmpty() ? "" : "OR v.MaVe = ? OR (v.MaDatVe = ? AND v.TrangThai <> N'Đã hủy') ");

        try (Connection conn = getConnection()) {
            Ve ve = null;
            String trangThaiVe = "";
            String trangThaiHD = "";
            java.sql.Date sqlNgayChieu = null;
            Time sqlGioBatDau = null;

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int col = 1;
                ps.setString(col++, cleanCode);
                ps.setString(col++, codeWithoutHash);
                ps.setString(col++, "%" + cleanCode + "%");
                if (!numberOnly.isEmpty()) {
                    int numVal = Integer.parseInt(numberOnly);
                    ps.setInt(col++, numVal);
                    ps.setInt(col++, numVal);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        ve = new Ve();
                        ve.setMaVe(rs.getInt("MaVe"));
                        ve.setMaDatVe(rs.getInt("MaDatVe"));
                        ve.setMaSuat(rs.getInt("MaSuat"));
                        ve.setMaGhe(rs.getInt("MaGhe"));
                        ve.setGiaVe(rs.getBigDecimal("GiaVe"));
                        ve.setMaQR(rs.getString("MaQR"));

                        trangThaiVe = rs.getString("TrangThaiVe");
                        ve.setTrangThai(trangThaiVe);

                        trangThaiHD = rs.getString("TrangThaiHD");

                        String hang = rs.getString("HangGhe");
                        int so = rs.getInt("SoGhe");
                        ve.setTenGhe((hang != null ? hang : "") + (so > 0 ? so : ""));
                        ve.setTenPhim(rs.getString("TenPhim"));
                        ve.setTenPhong(rs.getString("TenPhong"));

                        sqlNgayChieu = rs.getDate("NgayChieu");
                        if (sqlNgayChieu != null) ve.setNgayChieu(sqlNgayChieu.toString());

                        sqlGioBatDau = rs.getTime("GioBatDau");
                        if (sqlGioBatDau != null) ve.setGioChieu(sqlGioBatDau.toString().substring(0, 5));
                    }
                }
            }

            if (ve == null) {
                result.put("success", false);
                result.put("statusCode", "NOT_FOUND");
                result.put("message", "Không tìm thấy thông tin vé phù hợp với mã [" + cleanCode + "]!");
                return result;
            }

            result.put("ve", ve);

            // 1. Kiểm tra nếu vé hoặc đơn đặt vé đã bị hủy
            if ("Đã hủy".equalsIgnoreCase(trangThaiVe) || "Đã hủy".equalsIgnoreCase(trangThaiHD)) {
                result.put("success", false);
                result.put("statusCode", "CANCELLED");
                result.put("message", "Vé này hoặc đơn đặt vé đã bị HỦY! Không được phép vào phòng chiếu.");
                return result;
            }

            // 2. Kiểm tra nếu đơn chưa thanh toán
            if ("Chờ thanh toán".equalsIgnoreCase(trangThaiHD) || "Chờ thanh toán".equalsIgnoreCase(trangThaiVe)) {
                result.put("success", false);
                result.put("statusCode", "NOT_PAID");
                result.put("message", "Đơn vé đang ở trạng thái 'Chờ thanh toán'! Khách cần thanh toán trước khi vào rạp.");
                return result;
            }

            // 3. Kiểm tra chống gian lận: Vé ĐÃ CHECK-IN trước đó
            if ("Đã check-in".equalsIgnoreCase(trangThaiVe)) {
                result.put("success", false);
                result.put("statusCode", "ALREADY_CHECKED_IN");
                result.put("message", "CẢNH BÁO: Vé này ĐÃ ĐƯỢC SOÁT VÉ (CHECK-IN) trước đó rồi! Không cho phép vào lại.");
                return result;
            }

            // 4. Kiểm tra Thời gian Suất chiếu thông minh (Nếu không phải duyệt đặc cách)
            if (!forceCheckIn && sqlNgayChieu != null) {
                LocalDate today = LocalDate.now();
                LocalDate showDate = sqlNgayChieu.toLocalDate();

                if (!today.equals(showDate)) {
                    result.put("success", false);
                    result.put("statusCode", "WRONG_DATE");
                    result.put("canForce", true);
                    result.put("message", "Vé này chiếu ngày " + showDate + " (Hôm nay là " + today + "). Sai ngày chiếu!");
                    return result;
                }

                if (sqlGioBatDau != null) {
                    java.time.LocalTime nowTime = java.time.LocalTime.now();
                    java.time.LocalTime showTime = sqlGioBatDau.toLocalTime();

                    long minutesDiff = java.time.Duration.between(nowTime, showTime).toMinutes();

                    // Nếu đến quá sớm (trước giờ chiếu trên 45 phút)
                    if (minutesDiff > 45) {
                        result.put("success", false);
                        result.put("statusCode", "TOO_EARLY");
                        result.put("canForce", true);
                        result.put("message", "Chưa đến giờ vào rạp! Suất chiếu lúc " + ve.getGioChieu() + " (còn " + minutesDiff + " phút nữa). Rạp chỉ mở cửa trước 45 phút.");
                        return result;
                    }

                    // Nếu đến quá muộn (sau khi phim bắt đầu hơn 45 phút)
                    if (minutesDiff < -45) {
                        result.put("success", false);
                        result.put("statusCode", "EXPIRED");
                        result.put("canForce", true);
                        result.put("message", "Suất chiếu đã bắt đầu được " + Math.abs(minutesDiff) + " phút. Vé đã quá giờ quy định vào rạp!");
                        return result;
                    }
                }
            }

            // 5. Hợp lệ -> Cập nhật trạng thái vé thành "Đã check-in"
            String sqlUpdate = "UPDATE Ve SET TrangThai = N'Đã check-in' WHERE MaVe = ?";
            try (PreparedStatement psUp = conn.prepareStatement(sqlUpdate)) {
                psUp.setInt(1, ve.getMaVe());
                psUp.executeUpdate();
            }

            ve.setTrangThai("Đã check-in");
            result.put("success", true);
            result.put("statusCode", "SUCCESS");
            result.put("message", "Check-in thành công! Mời quý khách vào phòng chiếu " + (ve.getTenPhong() != null ? ve.getTenPhong() : "") + ".");
            return result;

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("statusCode", "ERROR");
            result.put("message", "Lỗi hệ thống khi soát vé: " + e.getMessage());
            return result;
        }
    }

    /**
     * Thống kê tiến độ soát vé trong ngày hôm nay
     */
    public Map<String, Object> getThongKeCheckInHomNay() {
        Map<String, Object> map = new HashMap<>();
        int tongVeHomNay = 0;
        int veDaCheckIn = 0;

        String sql = "SELECT " +
                "COUNT(CASE WHEN v.TrangThai IN (N'Đã bán', N'Đã check-in') THEN 1 END) AS TongVe, " +
                "COUNT(CASE WHEN v.TrangThai = N'Đã check-in' THEN 1 END) AS DaCheckIn " +
                "FROM Ve v " +
                "JOIN SuatChieu sc ON v.MaSuat = sc.MaSuat " +
                "WHERE CONVERT(date, sc.NgayChieu) = CONVERT(date, GETDATE())";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                tongVeHomNay = rs.getInt("TongVe");
                veDaCheckIn = rs.getInt("DaCheckIn");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        int veChuaCheckIn = Math.max(0, tongVeHomNay - veDaCheckIn);
        int tyLe = tongVeHomNay > 0 ? (veDaCheckIn * 100 / tongVeHomNay) : 0;

        map.put("tongVeHomNay", tongVeHomNay);
        map.put("veDaCheckIn", veDaCheckIn);
        map.put("veChuaCheckIn", veChuaCheckIn);
        map.put("tyLe", tyLe);
        return map;
    }

    /**
     * Lấy 15 vé vừa check-in gần nhất để làm nhật ký soát vé
     */
    public List<Ve> getLichSuCheckIn() {
        List<Ve> list = new ArrayList<>();
        String sql = "SELECT TOP 15 v.MaVe, v.MaDatVe, v.MaSuat, v.MaGhe, v.GiaVe, v.MaQR, v.TrangThai, " +
                "g.HangGhe, g.SoGhe, " +
                "p.TenPhim, pc.TenPhong, sc.NgayChieu, sc.GioBatDau " +
                "FROM Ve v " +
                "LEFT JOIN Ghe g ON v.MaGhe = g.MaGhe " +
                "LEFT JOIN SuatChieu sc ON v.MaSuat = sc.MaSuat " +
                "LEFT JOIN Phim p ON sc.MaPhim = p.MaPhim " +
                "LEFT JOIN PhongChieu pc ON sc.MaPhong = pc.MaPhong " +
                "WHERE v.TrangThai = N'Đã check-in' " +
                "ORDER BY v.MaVe DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Ve ve = new Ve();
                ve.setMaVe(rs.getInt("MaVe"));
                ve.setMaDatVe(rs.getInt("MaDatVe"));
                ve.setMaSuat(rs.getInt("MaSuat"));
                ve.setMaGhe(rs.getInt("MaGhe"));
                ve.setGiaVe(rs.getBigDecimal("GiaVe"));
                ve.setMaQR(rs.getString("MaQR"));
                ve.setTrangThai(rs.getString("TrangThai"));

                String hang = rs.getString("HangGhe");
                int so = rs.getInt("SoGhe");
                ve.setTenGhe((hang != null ? hang : "") + (so > 0 ? so : ""));
                ve.setTenPhim(rs.getString("TenPhim"));
                ve.setTenPhong(rs.getString("TenPhong"));

                java.sql.Date d = rs.getDate("NgayChieu");
                if (d != null) ve.setNgayChieu(d.toString());

                Time t = rs.getTime("GioBatDau");
                if (t != null) ve.setGioChieu(t.toString().substring(0, 5));

                list.add(ve);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
