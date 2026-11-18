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
    protected Session openSession() {
        return HibernateConfig.getFACTORY().openSession();
    }

    // Lấy toàn bộ combo, sắp xếp theo mã tăng dần
    /** [ComboRepository-getAll] SELECT toàn bộ danh mục, sắp xếp theo mã. Session tự đóng khi ra khỏi try. */
    public List<Combo> getAll() {
        try (Session session = openSession()) {
            return session.createQuery("SELECT c FROM Combo c ORDER BY c.maCombo", Combo.class).list();
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được dữ liệu combo.", e);
        }
    }

    // Lấy 1 combo theo mã khóa chính
    /** [ComboRepository-getOne] Chuyển mã đầu vào sang số rồi tìm theo khóa chính. Không có bản ghi thì trả null. */
    public Combo getOne(String maCombo) {
        if (maCombo == null || maCombo.trim().isEmpty()) {
            return null;
        }
        try (Session session = openSession()) {
            return session.find(Combo.class, util.DatabaseId.parse(maCombo));
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được dữ liệu combo.", e);
        }
    }

    // Tìm kiếm combo theo từ khóa (mã hoặc tên) + lọc trạng thái ("Đang bán" / "Ngừng bán")
    /** [ComboRepository-search] Ghép điều kiện khi có từ khóa/trạng thái. setParameter truyền giá trị riêng để tránh ghép đầu vào vào SQL. */
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
    /** [ComboRepository-getChiTiet] Lấy các dòng ChiTietCombo và tải sẵn SanPham để JSP dùng được sau khi đóng Session. */
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
                    .setParameter("ma", util.DatabaseId.parse(maCombo))
                    .list();
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được dữ liệu combo.", e);
        }
    }


    // Lưu combo và chi tiết trong cùng giao dịch; tạo combo không trừ kho.
    /** [ComboRepository-save] Bắt đầu giao dịch; kiểm tra phiên bản và các món; tính giá; lưu combo rồi lưu chi tiết; commit. Có lỗi thì rollback. */
    public boolean save(Combo combo, List<ChiTietCombo> details, int discount, boolean adding, String expected) {
        try (Session session = openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                Combo old = null;
                if (adding) {
                    combo.setMaCombo(null); // SQL Server cấp INT IDENTITY.
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
                java.math.BigDecimal total = kiemTraVaTinhTongGiaLe(session, details);
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
    /** [ComboRepository-fingerprint] Ghép nội dung combo và chi tiết theo thứ tự mã rồi băm SHA-256. So với dấu lúc mở form để phát hiện người khác đã sửa. */
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
    /** [ComboRepository-delete] Kiểm tra dữ liệu tham chiếu trước khi xóa. Các bước ghi cùng giao dịch để lỗi không để lại dữ liệu dở dang. */
    public boolean delete(String id) {
        Integer comboId = util.DatabaseId.parse(id);
        try (Session session = openSession()) {
            Transaction tx = session.beginTransaction();
            try {
                Combo combo = session.find(Combo.class, comboId, jakarta.persistence.LockModeType.PESSIMISTIC_WRITE);
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
    /** [CB-GIA] Đầu vào: sản phẩm được chọn. Đầu ra: tổng giá lẻ.
     * Đọc giá và tồn kho thật từ database; chỉ kiểm tra, không trừ kho.
     * Nếu một món sai thì ném lỗi để save() rollback toàn bộ giao dịch.
     */
    private java.math.BigDecimal kiemTraVaTinhTongGiaLe(Session session, List<ChiTietCombo> details) {
                // Kiểm tra tồn kho, trạng thái và lấy giá mới nhất ngay trước khi lưu.
                if (details.isEmpty()) throw new IllegalArgumentException("Hãy chọn ít nhất một sản phẩm.");
                java.math.BigDecimal total = java.math.BigDecimal.ZERO;
                sapXepTheoMaSanPham(details);
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
}
