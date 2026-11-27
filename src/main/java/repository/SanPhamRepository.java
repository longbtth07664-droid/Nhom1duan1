package repository;

import util.DatabaseId;

import jakarta.persistence.LockModeType;

import entity.SanPham;
import org.hibernate.Session;
import org.hibernate.Transaction;
import util.HibernateConfig;

import java.util.List;
import java.util.ConcurrentModificationException;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

// Tra cứu chức năng: docs/TRA_CUU_COMBO_SAN_PHAM_THONG_KE.txt
public class SanPhamRepository {
    protected Session openSession() {
        return HibernateConfig.getFACTORY().openSession();
    }

    // Lấy toàn bộ sản phẩm (dùng cho trang Quản lý sản phẩm)
    // [SP-SQL-DANH-SACH] Đọc danh sách theo mã.
    public List<SanPham> getAll() {
        try (Session session = openSession()) {
            return session.createQuery("SELECT sp FROM SanPham sp ORDER BY sp.maSP", SanPham.class).list();
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được danh sách sản phẩm.", e);
        }
    }

    // Lấy danh sách sản phẩm đang kinh doanh để đưa vào bảng chọn món khi tạo/sửa Combo
    // [SP-DANG-BAN] Chỉ lấy món đang kinh doanh cho form combo.
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
    public SanPham getOne(String maSP) {
        try (Session session = openSession()) {
            return session.find(SanPham.class, DatabaseId.parse(maSP));
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được sản phẩm.", e);
        }
    }

    // Tìm kiếm sản phẩm theo mã/tên và lọc theo trạng thái
    // [SP-SQL-TIM] Tìm theo mã, tên, loại; thêm điều kiện trạng thái nếu có chọn.
    public List<SanPham> search(String keyword, String trangThai) {
        try (Session session = openSession()) {
            StringBuilder hql = new StringBuilder("SELECT sp FROM SanPham sp WHERE 1=1");
            boolean coTuKhoa = keyword != null && !keyword.trim().isEmpty();
            boolean coTrangThai = trangThai != null && !trangThai.trim().isEmpty() && !"Tất cả".equals(trangThai);
            if (coTuKhoa) {
                hql.append(" AND (cast(sp.maSP as string) LIKE :kw OR sp.tenSP LIKE :kw OR sp.loaiSP LIKE :kw)");
            }
            if (coTrangThai) {
                hql.append(" AND sp.trangThai = :tt");
            }
            hql.append(" ORDER BY sp.maSP");

            org.hibernate.query.Query<SanPham> query = session.createQuery(hql.toString(), SanPham.class);
            if (coTuKhoa) {
                query.setParameter("kw", "%" + keyword.trim() + "%");
            }
            if (coTrangThai) {
                query.setParameter("tt", trangThai.trim());
            }
            return query.list();
        } catch (Exception e) {
            throw new IllegalStateException("Không tìm được sản phẩm.", e);
        }
    }

    // Thêm sản phẩm mới
    // [SP-SQL-THEM] Để SQL cấp mã tự tăng, persist rồi commit; thất bại rollback.
    public boolean add(SanPham sp) {
        try (Session session = openSession()) {
            Transaction tx = session.beginTransaction();
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
    // [SP-SQL-SUA] Khóa dòng, so phiên bản, giữ ảnh cũ nếu không chọn ảnh mới rồi merge.
    public boolean update(SanPham sp, String version) {
        Transaction tx = null;
        try (Session session = openSession()) {
            tx = session.beginTransaction();
            try {
                SanPham existing = session.find(SanPham.class, sp.getMaSP(), LockModeType.PESSIMISTIC_WRITE);
                // [SP-CHONG-GHI-DE] So sánh bản lúc mở form với bản mới nhất khi đã khóa dòng.
                if (existing == null || !fingerprint(existing).equals(version)) {
                    throw new ConcurrentModificationException("Sản phẩm đã thay đổi hoặc đã bị xóa.");
                }
                // Form sửa không chọn file mới thì giữ tên ảnh trong bản gốc đã khóa.
                if (sp.getHinhAnh() == null) sp.setHinhAnh(existing.getHinhAnh());
                session.merge(sp);
                tx.commit();
                return true;
            } catch (ConcurrentModificationException e) {
                if (tx.isActive()) tx.rollback();
                throw e;
            } catch (RuntimeException e) {
                if (tx.isActive()) tx.rollback();
                e.printStackTrace();
                return false;
            }
        }
    }

    /** Dấu dữ liệu của form sửa, gồm cả tồn kho để phát hiện bán hàng trong lúc mở form. */
    // [SP-PHIEN-BAN] Ghép các trường có độ dài, gồm tồn kho và ảnh, làm dấu dữ liệu lúc mở form.
    public String fingerprint(SanPham sp) {
        StringBuilder data = new StringBuilder();
        String[] fields = {sp.getMaSP().toString(), sp.getGiaBan().toPlainString(),
                String.valueOf(sp.getSoLuongTon()), sp.getTrangThai(), sp.getLoaiSP(),
                sp.getDonViTinh(), sp.getTenSP(), sp.getHinhAnh()};
        for (String field : fields) {
            // Ghi độ dài để hai chuỗi chứa dấu phân cách vẫn không bị nhầm.
            if (field == null) data.append("-1:");
            else data.append(field.length()).append(':').append(field);
        }
        return Base64.getEncoder().encodeToString(data.toString().getBytes(StandardCharsets.UTF_8));
    }

    // Kiểm tra sản phẩm đã nằm trong Combo hoặc Hóa đơn chưa (tránh lỗi khóa ngoại khi xóa)
    public boolean isSanPhamUsed(String maSP) {
        Integer productId = DatabaseId.parse(maSP);
        try (Session session = openSession()) {
            return demSoLanSuDung(session, productId) > 0;
        } catch (Exception e) {
            throw new IllegalStateException("Không kiểm tra được sản phẩm đã được sử dụng hay chưa.", e);
        }
    }

    // Xóa sản phẩm
    // [SP-SQL-XOA] Khóa dòng, kiểm tra lại tham chiếu, remove rồi commit.
    public boolean delete(String maSP) {
        Integer productId = DatabaseId.parse(maSP);
        Transaction tx = null;
        try (Session session = openSession()) {
            tx = session.beginTransaction();
            try {
                SanPham sp = session.find(SanPham.class, productId, LockModeType.PESSIMISTIC_WRITE);
                if (sp == null) throw new IllegalArgumentException("Sản phẩm không còn tồn tại.");
                if (demSoLanSuDung(session, productId) > 0)
                    throw new IllegalArgumentException("Sản phẩm đã được sử dụng.");
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

    // [SP-DA-SU-DUNG] Dùng chung cho nút xóa và kiểm tra lại trong giao dịch xóa.
    private long demSoLanSuDung(Session session, Integer maSP) {
        Number count = (Number) session.createNativeQuery(
                "SELECT (SELECT COUNT_BIG(*) FROM ChiTietCombo WHERE MaSP=:ma) "
                + "+ (SELECT COUNT_BIG(*) FROM ChiTietHoaDon WHERE MaSP=:ma)")
                .setParameter("ma", maSP).uniqueResult();
        return count.longValue();
    }
}
