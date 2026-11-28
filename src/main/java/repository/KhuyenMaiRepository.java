package repository;

import entity.KhachHang;
import entity.KhuyenMai;
import entity.SuatChieu;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class KhuyenMaiRepository {

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

    public List<KhuyenMai> getAll() {
        List<KhuyenMai> list = new ArrayList<>();
        String sql = "SELECT * FROM KhuyenMai ORDER BY MaKM DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public KhuyenMai getById(int id) {
        String sql = "SELECT * FROM KhuyenMai WHERE MaKM = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public KhuyenMai getByCode(String code) {
        if (code == null || code.trim().isEmpty()) return null;
        String sql = "SELECT * FROM KhuyenMai WHERE UPPER(LTRIM(RTRIM(MaCode))) = UPPER(LTRIM(RTRIM(?)))";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<KhuyenMai> getActiveVouchers() {
        List<KhuyenMai> list = new ArrayList<>();
        String sql = "SELECT * FROM KhuyenMai WHERE TrangThai = N'Đang áp dụng' AND NgayKetThuc >= GETDATE() ORDER BY PhanTramGiam DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean add(KhuyenMai km) {
        String sql = "INSERT INTO KhuyenMai (TenKM, MaCode, PhanTramGiam, SoTienGiamToiDa, DonToiThieu, " +
                     "GioChieuTu, GioChieuDen, ThuTrongTuan, TuoiToiThieu, TuoiToiDa, SoVeToiThieu, " +
                     "NgayBatDau, NgayKetThuc, TrangThai) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, km.getTenKM());
            ps.setString(2, km.getMaCode().toUpperCase().trim());
            ps.setBigDecimal(3, km.getPhanTramGiam() != null ? km.getPhanTramGiam() : BigDecimal.ZERO);
            ps.setBigDecimal(4, km.getSoTienGiamToiDa() != null ? km.getSoTienGiamToiDa() : BigDecimal.ZERO);
            ps.setBigDecimal(5, km.getDonToiThieu() != null ? km.getDonToiThieu() : BigDecimal.ZERO);

            if (km.getGioChieuTu() != null) ps.setTime(6, Time.valueOf(km.getGioChieuTu()));
            else ps.setNull(6, Types.TIME);

            if (km.getGioChieuDen() != null) ps.setTime(7, Time.valueOf(km.getGioChieuDen()));
            else ps.setNull(7, Types.TIME);

            ps.setString(8, km.getThuTrongTuan() != null ? km.getThuTrongTuan() : "ALL");

            if (km.getTuoiToiThieu() != null) ps.setInt(9, km.getTuoiToiThieu());
            else ps.setNull(9, Types.INTEGER);

            if (km.getTuoiToiDa() != null) ps.setInt(10, km.getTuoiToiDa());
            else ps.setNull(10, Types.INTEGER);

            ps.setInt(11, km.getSoVeToiThieu() > 0 ? km.getSoVeToiThieu() : 1);
            ps.setTimestamp(12, km.getNgayBatDau() != null ? Timestamp.valueOf(km.getNgayBatDau()) : new Timestamp(System.currentTimeMillis()));
            ps.setTimestamp(13, km.getNgayKetThuc() != null ? Timestamp.valueOf(km.getNgayKetThuc()) : Timestamp.valueOf(LocalDateTime.now().plusMonths(1)));
            ps.setString(14, km.getTrangThai() != null ? km.getTrangThai() : "Đang áp dụng");

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean update(KhuyenMai km) {
        String sql = "UPDATE KhuyenMai SET TenKM = ?, MaCode = ?, PhanTramGiam = ?, SoTienGiamToiDa = ?, DonToiThieu = ?, " +
                     "GioChieuTu = ?, GioChieuDen = ?, ThuTrongTuan = ?, TuoiToiThieu = ?, TuoiToiDa = ?, SoVeToiThieu = ?, " +
                     "NgayBatDau = ?, NgayKetThuc = ?, TrangThai = ? WHERE MaKM = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, km.getTenKM());
            ps.setString(2, km.getMaCode().toUpperCase().trim());
            ps.setBigDecimal(3, km.getPhanTramGiam());
            ps.setBigDecimal(4, km.getSoTienGiamToiDa());
            ps.setBigDecimal(5, km.getDonToiThieu());

            if (km.getGioChieuTu() != null) ps.setTime(6, Time.valueOf(km.getGioChieuTu()));
            else ps.setNull(6, Types.TIME);

            if (km.getGioChieuDen() != null) ps.setTime(7, Time.valueOf(km.getGioChieuDen()));
            else ps.setNull(7, Types.TIME);

            ps.setString(8, km.getThuTrongTuan());

            if (km.getTuoiToiThieu() != null) ps.setInt(9, km.getTuoiToiThieu());
            else ps.setNull(9, Types.INTEGER);

            if (km.getTuoiToiDa() != null) ps.setInt(10, km.getTuoiToiDa());
            else ps.setNull(10, Types.INTEGER);

            ps.setInt(11, km.getSoVeToiThieu());
            ps.setTimestamp(12, Timestamp.valueOf(km.getNgayBatDau()));
            ps.setTimestamp(13, Timestamp.valueOf(km.getNgayKetThuc()));
            ps.setString(14, km.getTrangThai());
            ps.setInt(15, km.getMaKM());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM KhuyenMai WHERE MaKM = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            // Nếu đã phát sinh hóa đơn liên kết, chuyển trạng thái thành Ngưng áp dụng
            String sqlUpdate = "UPDATE KhuyenMai SET TrangThai = N'Đã hủy' WHERE MaKM = ?";
            try (Connection conn2 = getConnection();
                 PreparedStatement ps2 = conn2.prepareStatement(sqlUpdate)) {
                ps2.setInt(1, id);
                return ps2.executeUpdate() > 0;
            } catch (SQLException ex) {
                ex.printStackTrace();
                return false;
            }
        }
    }

    private KhuyenMai mapResultSet(ResultSet rs) throws SQLException {
        KhuyenMai km = new KhuyenMai();
        km.setMaKM(rs.getInt("MaKM"));
        km.setTenKM(rs.getString("TenKM"));
        km.setMaCode(rs.getString("MaCode"));
        km.setPhanTramGiam(rs.getBigDecimal("PhanTramGiam"));
        km.setSoTienGiamToiDa(rs.getBigDecimal("SoTienGiamToiDa"));
        km.setDonToiThieu(rs.getBigDecimal("DonToiThieu"));

        try {
            Time tu = rs.getTime("GioChieuTu");
            if (tu != null) km.setGioChieuTu(tu.toLocalTime());
        } catch (Exception ignored) {}

        try {
            Time den = rs.getTime("GioChieuDen");
            if (den != null) km.setGioChieuDen(den.toLocalTime());
        } catch (Exception ignored) {}

        try {
            km.setThuTrongTuan(rs.getString("ThuTrongTuan"));
        } catch (Exception ignored) {}

        try {
            int tuTuoi = rs.getInt("TuoiToiThieu");
            if (!rs.wasNull()) km.setTuoiToiThieu(tuTuoi);
        } catch (Exception ignored) {}

        try {
            int denTuoi = rs.getInt("TuoiToiDa");
            if (!rs.wasNull()) km.setTuoiToiDa(denTuoi);
        } catch (Exception ignored) {}

        try {
            km.setSoVeToiThieu(rs.getInt("SoVeToiThieu"));
        } catch (Exception ignored) {
            km.setSoVeToiThieu(1);
        }

        Timestamp start = rs.getTimestamp("NgayBatDau");
        if (start != null) km.setNgayBatDau(start.toLocalDateTime());

        Timestamp end = rs.getTimestamp("NgayKetThuc");
        if (end != null) km.setNgayKetThuc(end.toLocalDateTime());

        km.setTrangThai(rs.getString("TrangThai"));
        return km;
    }
}
