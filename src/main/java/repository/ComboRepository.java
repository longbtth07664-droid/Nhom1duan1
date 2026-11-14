package repository;

import entity.ChiTietCombo;
import entity.Combo;
import org.hibernate.Session;
import org.hibernate.Transaction;
import util.HibernateConfig;

import java.util.ArrayList;
import java.util.List;

// Repository xử lý mọi thao tác CSDL cho module Combo (Hibernate ORM)
public class ComboRepository {

    // Lấy toàn bộ combo, sắp xếp theo mã tăng dần
    public List<Combo> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
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
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.find(Combo.class, maCombo.trim());
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được dữ liệu combo.", e);
        }
    }

    // Tìm kiếm combo theo từ khóa (mã hoặc tên) + lọc trạng thái ("Đang bán" / "Ngừng bán")
    public List<Combo> search(String keyword, String trangThai) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            StringBuilder hql = new StringBuilder("SELECT c FROM Combo c WHERE 1=1");

            // Xác định có cần lọc theo từ khóa và trạng thái hay không
            boolean coKeyword = (keyword != null && !keyword.trim().isEmpty());
            boolean coTrangThai = (trangThai != null && !trangThai.trim().isEmpty()
                    && !"Tất cả".equalsIgnoreCase(trangThai.trim()));

            // Ghép thêm điều kiện tìm kiếm vào câu HQL
            if (coKeyword) {
                hql.append(" AND (c.maCombo LIKE :kw OR c.tenCombo LIKE :kw)");
            }
            if (coTrangThai) {
                hql.append(" AND c.trangThai = :tt");
            }
            hql.append(" ORDER BY c.maCombo");

            // Gán giá trị tham số
            var query = session.createQuery(hql.toString(), Combo.class);
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

    // Tự sinh mã combo tiếp theo: CB01, CB02,..., CB10, CB11
    // Dùng Native SQL với TRY_CAST để trích số lớn nhất hiện có rồi +1
    public String generateId() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String sql = "SELECT MAX(TRY_CAST(SUBSTRING(MaCombo, 3, LEN(MaCombo)) AS INT)) "
                    + "FROM Combo WHERE MaCombo LIKE 'CB%'";
            Object result = session.createNativeQuery(sql).uniqueResult();
            int next = (result != null) ? ((Number) result).intValue() + 1 : 1;
            return String.format("CB%02d", next); // Đệm 0 cho đủ 2 chữ số
        } catch (Exception e) {
            e.printStackTrace();
            throw new IllegalStateException("Không sinh được mã combo.", e);
        }
    }

    // Lấy danh sách sản phẩm lẻ bên trong 1 combo
    // JOIN FETCH ct.sanPham → tải sẵn thông tin sản phẩm trước khi đóng Session,
    //                         tránh lỗi LazyInitializationException
    public List<ChiTietCombo> getChiTiet(String maCombo) {
        if (maCombo == null || maCombo.trim().isEmpty()) {
            return new ArrayList<>();
        }
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT ct FROM ChiTietCombo ct "
                    + "JOIN FETCH ct.sanPham "
                    + "WHERE ct.maCombo = :ma "
                    + "ORDER BY ct.maSP";
            return session.createQuery(hql, ChiTietCombo.class)
                    .setParameter("ma", maCombo.trim())
                    .list();
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được dữ liệu combo.", e);
        }
    }


    // Lưu combo và chi tiết trong cùng giao dịch; tạo combo không trừ kho.
    public boolean save(Combo combo, List<ChiTietCombo> details, int discount, boolean adding, String expected) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                Combo old = null;
                if (adding) {
                    // Khóa lúc cấp mã để các yêu cầu đồng thời không dùng chung mã.
                    Number max = (Number) session.createNativeQuery(
                        "SELECT COALESCE(MAX(TRY_CAST(SUBSTRING(MaCombo,3,20) AS BIGINT)),0) "
                        + "FROM Combo WITH (TABLOCKX,HOLDLOCK)").uniqueResult();
                    String suggested = combo.getMaCombo();
                    combo.setMaCombo(String.format("CB%02d", max.longValue() + 1));
                    // Nếu mã gợi ý vừa được người khác dùng, đồng bộ lại tên ảnh mặc định.
                    if ((suggested.toLowerCase(java.util.Locale.ROOT) + ".jpg").equals(combo.getHinhAnh()))
                        combo.setHinhAnh(combo.getMaCombo().toLowerCase(java.util.Locale.ROOT) + ".jpg");
                    combo.setTrangThai("Đang bán");
                } else {
                    old = session.find(Combo.class, combo.getMaCombo(), jakarta.persistence.LockModeType.PESSIMISTIC_WRITE);
                    if (old == null) throw new IllegalArgumentException("Combo đã bị xóa.");
                    List<ChiTietCombo> previous = session.createQuery(
                        "FROM ChiTietCombo WHERE maCombo = :ma ORDER BY maSP", ChiTietCombo.class)
                        .setParameter("ma", combo.getMaCombo()).list();
                    if (!fingerprint(old, previous).equals(expected))
                        throw new IllegalArgumentException("Combo đã được người khác sửa. Hãy tải lại trang.");
                }
                // Kiểm tra tồn kho, trạng thái và lấy giá mới nhất ngay trước khi lưu.
                if (details.isEmpty()) throw new IllegalArgumentException("Hãy chọn ít nhất một sản phẩm.");
                java.math.BigDecimal total = java.math.BigDecimal.ZERO;
                details.sort(java.util.Comparator.comparing(ChiTietCombo::getMaSP));
                for (ChiTietCombo detail : details) {
                    entity.SanPham product = session.find(entity.SanPham.class, detail.getMaSP(),
                        jakarta.persistence.LockModeType.PESSIMISTIC_READ);
                    if (product == null) throw new IllegalArgumentException("Sản phẩm không còn tồn tại.");
                    if (!"Đang kinh doanh".equals(product.getTrangThai()))
                        throw new IllegalArgumentException(product.getTenSP() + " đã ngừng kinh doanh.");
                    if (detail.getSoLuong() < 1 || detail.getSoLuong() > product.getSoLuongTon())
                        throw new IllegalArgumentException(product.getTenSP() + " chỉ còn "
                            + product.getSoLuongTon() + ". Vui lòng giảm số lượng.");
                    total = total.add(product.getGiaBan().multiply(java.math.BigDecimal.valueOf(detail.getSoLuong())));
                    detail.setMaCombo(combo.getMaCombo());
                }
                // Giữ giá cũ khi sửa nếu quản lý chưa chọn tính lại; không cần đổi bảng dữ liệu.
                if (discount == -1 && !adding) combo.setGiaCombo(old.getGiaCombo());
                else {
                    if (discount != 0 && discount != 10 && discount != 20 && discount != 50)
                        throw new IllegalArgumentException("Mức giảm giá không hợp lệ.");
                    combo.setGiaCombo(total.multiply(java.math.BigDecimal.valueOf(100 - discount))
                        .divide(java.math.BigDecimal.valueOf(100), 0, java.math.RoundingMode.HALF_UP));
                }
                if (combo.getGiaCombo().signum() <= 0 || combo.getGiaCombo().precision() > 18)
                    throw new IllegalArgumentException("Giá combo vượt giới hạn cho phép.");
                if (adding) session.persist(combo);
                else {
                    session.merge(combo);
                    session.createQuery("DELETE FROM ChiTietCombo WHERE maCombo = :ma")
                        .setParameter("ma", combo.getMaCombo()).executeUpdate();
                    session.flush();
                    session.clear(); // Bỏ chi tiết cũ trong cache trước khi thêm lại cùng khóa.
                }
                for (ChiTietCombo detail : details) session.persist(detail);
                tx.commit();
                return true;
            } catch (RuntimeException e) {
                if (tx.isActive()) tx.rollback(); // Hoàn tác khi session vẫn đang mở.
                throw e;
            }
        }
    }

    // Phát hiện thay đổi đồng thời bằng nội dung, giữ nguyên cấu trúc bảng hiện có.
    public String fingerprint(Combo combo, List<ChiTietCombo> details) {
        StringBuilder data = new StringBuilder(combo.toString());
        data.append('|').append(combo.getMoTa()).append('|').append(combo.getHinhAnh());
        details.stream().sorted(java.util.Comparator.comparing(ChiTietCombo::getMaSP))
            .forEach(d -> data.append('|').append(d.toString()));
        try {
            return java.util.Base64.getEncoder().encodeToString(
                java.security.MessageDigest.getInstance("SHA-256").digest(
                    data.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8)));
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }

    // Chỉ xóa khi combo tồn tại và chưa được sử dụng trong hóa đơn.
    public boolean delete(String id) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                Combo combo = session.find(Combo.class, id, jakarta.persistence.LockModeType.PESSIMISTIC_WRITE);
                if (combo == null) throw new IllegalArgumentException("Combo không tồn tại hoặc đã bị xóa.");
                Number count = (Number) session.createNativeQuery(
                    "SELECT COUNT(*) FROM ChiTietHoaDon WHERE MaCombo = :ma")
                    .setParameter("ma", id).uniqueResult();
                if (count.longValue() > 0)
                    throw new IllegalArgumentException("Combo đã có trong hóa đơn. Hãy chuyển sang Ngừng bán.");
                session.createQuery("DELETE FROM ChiTietCombo WHERE maCombo = :ma")
                    .setParameter("ma", id).executeUpdate();
                session.remove(combo);
                tx.commit();
                return true;
            } catch (RuntimeException e) {
                if (tx.isActive()) tx.rollback();
                throw e;
            }
        }
    }
}
