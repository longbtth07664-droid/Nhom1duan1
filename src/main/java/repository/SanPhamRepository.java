package repository;

import entity.SanPham;
import org.hibernate.Session;
import org.hibernate.Transaction;
import util.HibernateConfig;

import java.util.List;

public class SanPhamRepository {
    protected Session openSession() {
        return HibernateConfig.getFACTORY().openSession();
    }

    // Lấy toàn bộ sản phẩm (dùng cho trang Quản lý sản phẩm)
    /** [SanPhamRepository-getAll] SELECT toàn bộ danh mục, sắp xếp theo mã. Session tự đóng khi ra khỏi try. */
    public List<SanPham> getAll() {
        try (Session session = openSession()) {
            return session.createQuery("SELECT sp FROM SanPham sp ORDER BY sp.maSP", SanPham.class).list();
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được danh sách sản phẩm.", e);
        }
    }

    // Lấy danh sách sản phẩm đang kinh doanh để đưa vào bảng chọn món khi tạo/sửa Combo
    public List<SanPham> getAllDangKinhDoanh() {
        try (Session session = openSession()) {
            return session.createQuery(
                    "SELECT sp FROM SanPham sp WHERE sp.trangThai = :tt ORDER BY sp.maSP", SanPham.class)
                    .setParameter("tt", "Đang kinh doanh")
                    .list();
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được danh sách sản phẩm.", e);
        }
    }

    // Lấy 1 sản phẩm theo mã
    /** [SanPhamRepository-getOne] Chuyển mã đầu vào sang số rồi tìm theo khóa chính. Không có bản ghi thì trả null. */
    public SanPham getOne(String maSP) {
        try (Session session = openSession()) {
            return session.find(SanPham.class, util.DatabaseId.parse(maSP));
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được sản phẩm.", e);
        }
    }

    // Tìm kiếm sản phẩm theo mã/tên và lọc theo trạng thái
    /** [SanPhamRepository-search] Ghép điều kiện khi có từ khóa/trạng thái. setParameter truyền giá trị riêng để tránh ghép đầu vào vào SQL. */
    public List<SanPham> search(String keyword, String trangThai) {
        try (Session session = openSession()) {
            StringBuilder hql = new StringBuilder("SELECT sp FROM SanPham sp WHERE 1=1");
            if (keyword != null && !keyword.trim().isEmpty()) {
                hql.append(" AND (cast(sp.maSP as string) LIKE :kw OR sp.tenSP LIKE :kw OR sp.loaiSP LIKE :kw)");
            }
            if (trangThai != null && !trangThai.trim().isEmpty() && !"Tất cả".equals(trangThai)) {
                hql.append(" AND sp.trangThai = :tt");
            }
            hql.append(" ORDER BY sp.maSP");

            org.hibernate.query.Query<SanPham> query = session.createQuery(hql.toString(), SanPham.class);
            if (keyword != null && !keyword.trim().isEmpty()) {
                query.setParameter("kw", "%" + keyword.trim() + "%");
            }
            if (trangThai != null && !trangThai.trim().isEmpty() && !"Tất cả".equals(trangThai)) {
                query.setParameter("tt", trangThai.trim());
            }
            return query.list();
        } catch (Exception e) {
            throw new IllegalStateException("Không tìm được sản phẩm.", e);
        }
    }

    // Thêm sản phẩm mới
    /** [SanPhamRepository-add] Đặt ID null để SQL Server tự tăng; persist ghi bản mới; commit xác nhận, rollback khi lỗi. */
    public boolean add(SanPham sp) {
        Transaction tx = null;
        try (Session session = openSession()) {
            tx = session.beginTransaction();
            try {
            sp.setMaSP(null);
            session.persist(sp); // SQL Server cấp mã IDENTITY, không chèn mã từ form.
            tx.commit();
            return true;
            } catch (RuntimeException e) {
                if (tx.isActive()) tx.rollback();
                e.printStackTrace();
                return false;
            }
        }
    }

    // Cập nhật sản phẩm
    /** [SanPhamRepository-update] Tìm và khóa bản hiện có trước khi merge. Ngăn sửa bản đã bị xóa thành một bản mới. */
    public boolean update(SanPham sp) {
        Transaction tx = null;
        try (Session session = openSession()) {
            tx = session.beginTransaction();
            try {
            SanPham existing = session.find(SanPham.class, sp.getMaSP(), jakarta.persistence.LockModeType.PESSIMISTIC_WRITE);
            if (existing == null) throw new IllegalArgumentException("Sản phẩm không còn tồn tại.");
            session.merge(sp);
            tx.commit();
            return true;
            } catch (RuntimeException e) {
                if (tx.isActive()) tx.rollback();
                e.printStackTrace();
                return false;
            }
        }
    }

    // Kiểm tra sản phẩm đã nằm trong Combo hoặc Hóa đơn chưa (tránh lỗi khóa ngoại khi xóa)
    /** [SanPhamRepository-isSanPhamUsed] Đếm tham chiếu trong ChiTietCombo và ChiTietHoaDon. Có ít nhất một tham chiếu thì không cho xóa. */
    public boolean isSanPhamUsed(String maSP) {
        Integer productId = util.DatabaseId.parse(maSP);
        try (Session session = openSession()) {
            Object cntCombo = session.createNativeQuery("SELECT COUNT(*) FROM ChiTietCombo WHERE MaSP = :ma")
                    .setParameter("ma", productId).uniqueResult();
            Object cntHD = session.createNativeQuery("SELECT COUNT(*) FROM ChiTietHoaDon WHERE MaSP = :ma")
                    .setParameter("ma", productId).uniqueResult();
            int c1 = (cntCombo != null) ? ((Number) cntCombo).intValue() : 0;
            int c2 = (cntHD != null) ? ((Number) cntHD).intValue() : 0;
            return (c1 + c2) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return true;
        }
    }

    // Xóa sản phẩm
    /** [SanPhamRepository-delete] Kiểm tra dữ liệu tham chiếu trước khi xóa. Các bước ghi cùng giao dịch để lỗi không để lại dữ liệu dở dang. */
    public boolean delete(String maSP) {
        Integer productId = util.DatabaseId.parse(maSP);
        Transaction tx = null;
        try (Session session = openSession()) {
            tx = session.beginTransaction();
            try {
            SanPham sp = session.find(SanPham.class, productId, jakarta.persistence.LockModeType.PESSIMISTIC_WRITE);
            if (sp == null) throw new IllegalArgumentException("Sản phẩm không còn tồn tại.");
            Number used = (Number) session.createNativeQuery(
                "SELECT (SELECT COUNT_BIG(*) FROM ChiTietCombo WHERE MaSP=:ma) "
                + "+ (SELECT COUNT_BIG(*) FROM ChiTietHoaDon WHERE MaSP=:ma)")
                .setParameter("ma", productId).uniqueResult();
            if (used.longValue() > 0) throw new IllegalArgumentException("Sản phẩm đã được sử dụng.");
            session.remove(sp);
            tx.commit();
            return true;
            } catch (RuntimeException e) {
                if (tx.isActive()) tx.rollback();
                e.printStackTrace();
                return false;
            }
        }
    }
}
