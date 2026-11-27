package repository;

import util.DatabaseId;

import entity.SanPham;

import jakarta.persistence.LockModeType;

import java.math.RoundingMode;

import java.math.BigDecimal;

import entity.ChiTietCombo;
import entity.Combo;
import org.hibernate.Session;
import org.hibernate.Transaction;
import util.HibernateConfig;

import java.util.ArrayList;
import java.util.List;

// Repository xử lý mọi thao tác CSDL cho module Combo (Hibernate ORM)
// Tra cứu chức năng: docs/TRA_CUU_COMBO_SAN_PHAM_THONG_KE.txt
public class ComboRepository {
    protected Session openSession() {
        return HibernateConfig.getFACTORY().openSession();
    }

    // Lấy toàn bộ combo, sắp xếp theo mã tăng dần
    // [CB-SQL-DANH-SACH] Đọc toàn bộ combo theo mã tăng dần.
    public List<Combo> getAll() {
        try (Session session = openSession()) {
            return session.createQuery("SELECT c FROM Combo c ORDER BY c.maCombo", Combo.class).list();
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được dữ liệu combo.", e);
        }
    }

    // Lấy 1 combo theo mã khóa chính
    public Combo getOne(String maCombo) {
        if (maCombo == null || maCombo.trim().isEmpty()) {
            return null;
        }
        try (Session session = openSession()) {
            return session.find(Combo.class, DatabaseId.parse(maCombo));
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được dữ liệu combo.", e);
        }
    }

    // Tìm kiếm combo theo từ khóa (mã hoặc tên) + lọc trạng thái ("Đang bán" / "Ngừng bán")
    // [CB-SQL-TIM] Tìm mã/tên và trạng thái; truyền đầu vào bằng setParameter.
    public List<Combo> search(String keyword, String trangThai) {
        try (Session session = openSession()) {
            StringBuilder hql = new StringBuilder("SELECT c FROM Combo c WHERE 1=1");

            // Xác định có cần lọc theo từ khóa và trạng thái hay không
            boolean coKeyword = (keyword != null && !keyword.trim().isEmpty());
            boolean coTrangThai = (trangThai != null && !trangThai.trim().isEmpty()
                    && !"Tất cả".equalsIgnoreCase(trangThai.trim()));

            // Ghép thêm điều kiện tìm kiếm vào câu HQL
            if (coKeyword) {
                hql.append(" AND (cast(c.maCombo as string) LIKE :kw OR c.tenCombo LIKE :kw)");
            }
            if (coTrangThai) {
                hql.append(" AND c.trangThai = :tt");
            }
            hql.append(" ORDER BY c.maCombo");

            // Gán giá trị tham số
            org.hibernate.query.Query<Combo> query = session.createQuery(hql.toString(), Combo.class);
            if (coKeyword) {
                query.setParameter("kw", "%" + keyword.trim() + "%");
            }
            if (coTrangThai) {
                query.setParameter("tt", trangThai.trim());
            }

            return query.list();
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được dữ liệu combo.", e);
        }
    }

    // Lấy danh sách sản phẩm lẻ bên trong 1 combo
    // JOIN FETCH ct.sanPham → tải sẵn thông tin sản phẩm trước khi đóng Session,
    //                         tránh lỗi LazyInitializationException
    // [CB-SQL-CHI-TIET] JOIN FETCH tải sẵn tên/giá sản phẩm trước khi đóng session.
    public List<ChiTietCombo> getChiTiet(String maCombo) {
        if (maCombo == null || maCombo.trim().isEmpty()) {
            return new ArrayList<>();
        }
        try (Session session = openSession()) {
            String hql = "SELECT ct FROM ChiTietCombo ct "
                    + "JOIN FETCH ct.sanPham "
                    + "WHERE ct.maCombo = :ma "
                    + "ORDER BY ct.maSP";
            return session.createQuery(hql, ChiTietCombo.class)
                    .setParameter("ma", DatabaseId.parse(maCombo))
                    .list();
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được dữ liệu combo.", e);
        }
    }


    // Lưu combo và chi tiết trong cùng giao dịch; tạo combo không trừ kho.
    // [CB-SQL-LUU] Khóa bản sửa, kiểm tra phiên bản, tính giá, lưu cha và chi tiết; lỗi thì rollback.
    public boolean save(Combo combo, List<ChiTietCombo> details, int discount, boolean adding, String expected) {
        try (Session session = openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                Combo old = null;
                if (adding) {
                    combo.setMaCombo(null); // SQL Server cấp INT IDENTITY.
                    combo.setTrangThai("Đang bán");
                } else {
                    old = session.find(Combo.class, combo.getMaCombo(), LockModeType.PESSIMISTIC_WRITE);
                    if (old == null) throw new IllegalArgumentException("Combo đã bị xóa.");
                    List<ChiTietCombo> previous = session.createQuery(
                        "FROM ChiTietCombo WHERE maCombo = :ma ORDER BY maSP", ChiTietCombo.class)
                        .setParameter("ma", combo.getMaCombo()).list();
                    if (!fingerprint(old, previous).equals(expected))
                        throw new IllegalArgumentException("Combo đã được người khác sửa. Hãy tải lại trang.");
                    if (combo.getHinhAnh() == null || combo.getHinhAnh().isEmpty()) {
                        combo.setHinhAnh(old.getHinhAnh());
                    }
                }
                boolean dangBan = "Đang bán".equals(combo.getTrangThai());
                BigDecimal total = kiemTraVaTinhTongGiaLe(session, details, dangBan);
                if (discount == -1 && !adding) combo.setGiaCombo(old.getGiaCombo());
                else combo.setGiaCombo(tinhGiaSauGiam(total, discount));
                if (combo.getGiaCombo().signum() <= 0 || combo.getGiaCombo().precision() > 18)
                    throw new IllegalArgumentException("Giá combo vượt giới hạn cho phép.");
                if (adding) {
                    session.persist(combo); // IDENTITY đã được cấp trước khi lưu các dòng con.
                    if (combo.getHinhAnh() == null || combo.getHinhAnh().isEmpty())
                        combo.setHinhAnh(combo.getMaCombo() + ".jpg");
                }
                else {
                    session.merge(combo);
                    session.createQuery("DELETE FROM ChiTietCombo WHERE maCombo = :ma")
                        .setParameter("ma", combo.getMaCombo()).executeUpdate();
                    session.flush();
                    session.clear(); // Bỏ chi tiết cũ trong cache trước khi thêm lại cùng khóa.
                }
                for (ChiTietCombo detail : details) {
                    detail.setMaCombo(combo.getMaCombo());
                    session.persist(detail);
                }
                tx.commit();
                return true;
            } catch (RuntimeException e) {
                if (tx.isActive()) tx.rollback(); // Hoàn tác khi session vẫn đang mở.
                throw e;
            }
        }
    }

    // Phát hiện thay đổi đồng thời bằng nội dung, giữ nguyên cấu trúc bảng hiện có.
    // [CB-PHIEN-BAN] Tạo dấu nội dung, so với lúc mở form để tránh ghi đè thay đổi của người khác.
    public String fingerprint(Combo combo, List<ChiTietCombo> details) {
        StringBuilder data = new StringBuilder(combo.toString());
        data.append('|').append(combo.getMoTa()).append('|').append(combo.getHinhAnh());
        List<ChiTietCombo> banSao = new ArrayList<>(details);
        sapXepTheoMaSanPham(banSao);
        for (ChiTietCombo chiTiet : banSao) {
            data.append('|').append(chiTiet.toString());
        }
        try {
            return java.util.Base64.getEncoder().encodeToString(
                java.security.MessageDigest.getInstance("SHA-256").digest(
                    data.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8)));
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }

    // Chỉ xóa khi combo tồn tại và chưa được sử dụng trong hóa đơn.
    // [CB-SQL-XOA] Chặn combo đã có hóa đơn; xóa chi tiết trước rồi xóa combo trong cùng giao dịch.
    public boolean delete(String id) {
        Integer comboId = DatabaseId.parse(id);
        try (Session session = openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                Combo combo = session.find(Combo.class, comboId, LockModeType.PESSIMISTIC_WRITE);
                if (combo == null) throw new IllegalArgumentException("Combo không tồn tại hoặc đã bị xóa.");
                Number count = (Number) session.createNativeQuery(
                    "SELECT COUNT(*) FROM ChiTietHoaDon WHERE MaCombo = :ma")
                    .setParameter("ma", comboId).uniqueResult();
                if (count.longValue() > 0)
                    throw new IllegalArgumentException("Combo đã có trong hóa đơn. Hãy chuyển sang Ngừng bán.");
                session.createQuery("DELETE FROM ChiTietCombo WHERE maCombo = :ma")
                    .setParameter("ma", comboId).executeUpdate();
                session.remove(combo);
                tx.commit();
                return true;
            } catch (RuntimeException e) {
                if (tx.isActive()) tx.rollback();
                throw e;
            }
        }
    }
    /** [CB-GIA] Tính tổng giá lẻ. Combo đang bán cần đủ tồn và món còn kinh doanh.
     * Combo ngừng bán được giữ công thức cũ dù nguyên liệu hết hàng.
     */
    private BigDecimal kiemTraVaTinhTongGiaLe(Session session, List<ChiTietCombo> details, boolean dangBan) {
        if (details.isEmpty()) throw new IllegalArgumentException("Hãy chọn ít nhất một sản phẩm.");
        BigDecimal total = BigDecimal.ZERO;
        sapXepTheoMaSanPham(details);
        for (ChiTietCombo detail : details) {
            SanPham product = session.find(SanPham.class, detail.getMaSP(),
                    LockModeType.PESSIMISTIC_READ);
            if (product == null) throw new IllegalArgumentException("Sản phẩm không còn tồn tại.");
            if (detail.getSoLuong() < 1) throw new IllegalArgumentException("Số lượng phải từ 1 trở lên.");
            if (dangBan && !"Đang kinh doanh".equals(product.getTrangThai()))
                throw new IllegalArgumentException(product.getTenSP() + " đã ngừng kinh doanh.");
            if (dangBan && detail.getSoLuong() > product.getSoLuongTon())
                throw new IllegalArgumentException(product.getTenSP() + " chỉ còn "
                        + product.getSoLuongTon() + ". Vui lòng giảm số lượng.");
            total = total.add(product.getGiaBan().multiply(BigDecimal.valueOf(detail.getSoLuong())));
        }
        return total;
    }
    /** [CB-SAPXEP] Sắp xếp chèn bằng vòng lặp, tăng dần theo mã sản phẩm.
     * Giữ thứ tự khi mã bằng nhau. Dùng cùng thứ tự khóa sản phẩm khi lưu
     * và cùng thứ tự tạo dấu phiên bản; không phụ thuộc thứ tự checkbox.
     */
    private void sapXepTheoMaSanPham(List<ChiTietCombo> danhSach) {
        for (int i = 1; i < danhSach.size(); i++) {
            ChiTietCombo hienTai = danhSach.get(i);
            int j = i - 1;
            while (j >= 0 && danhSach.get(j).getMaSP() > hienTai.getMaSP()) {
                danhSach.set(j + 1, danhSach.get(j));
                j--;
            }
            danhSach.set(j + 1, hienTai);
        }
    }
    // [CB-GIAM-GIA] Giá combo = tổng (giá sản phẩm × số lượng) × (100 - % giảm) / 100.
    // BigDecimal giữ tiền chính xác; HALF_UP làm tròn tới một đồng.
    private BigDecimal tinhGiaSauGiam(BigDecimal tongGiaLe, int giamGia) {
        if (giamGia != 0 && giamGia != 10 && giamGia != 20 && giamGia != 50)
            throw new IllegalArgumentException("Mức giảm giá không hợp lệ.");
        return tongGiaLe.multiply(BigDecimal.valueOf(100 - giamGia))
                .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
    }

}
