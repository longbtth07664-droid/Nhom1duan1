package repository;

import entity.SanPham;
import org.hibernate.Session;
import org.hibernate.Transaction;
import util.HibernateConfig;

import java.util.ArrayList;
import java.util.List;

public class SanPhamRepository {

    // Lấy toàn bộ sản phẩm (dùng cho trang Quản lý sản phẩm)
    public List<SanPham> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("SELECT sp FROM SanPham sp ORDER BY sp.maSP", SanPham.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // Lấy danh sách sản phẩm đang kinh doanh để đưa vào bảng chọn món khi tạo/sửa Combo
    public List<SanPham> getAllDangKinhDoanh() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT sp FROM SanPham sp WHERE sp.trangThai = :tt ORDER BY sp.maSP", SanPham.class)
                    .setParameter("tt", "Đang kinh doanh")
                    .list();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // Lấy 1 sản phẩm theo mã
    public SanPham getOne(String maSP) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.find(SanPham.class, maSP);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // Tìm kiếm sản phẩm theo mã/tên và lọc theo trạng thái
    public List<SanPham> search(String keyword, String trangThai) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            StringBuilder hql = new StringBuilder("SELECT sp FROM SanPham sp WHERE 1=1");
            if (keyword != null && !keyword.trim().isEmpty()) {
                hql.append(" AND (sp.maSP LIKE :kw OR sp.tenSP LIKE :kw OR sp.loaiSP LIKE :kw)");
            }
            if (trangThai != null && !trangThai.trim().isEmpty() && !"Tất cả".equals(trangThai)) {
                hql.append(" AND sp.trangThai = :tt");
            }
            hql.append(" ORDER BY sp.maSP");

            var query = session.createQuery(hql.toString(), SanPham.class);
            if (keyword != null && !keyword.trim().isEmpty()) {
                query.setParameter("kw", "%" + keyword.trim() + "%");
            }
            if (trangThai != null && !trangThai.trim().isEmpty() && !"Tất cả".equals(trangThai)) {
                query.setParameter("tt", trangThai.trim());
            }
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // Tự sinh mã SP tiếp theo (VD: SP01..SP10 -> SP11)
    public String generateId() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String sql = "SELECT MAX(TRY_CAST(SUBSTRING(MaSP, 3, LEN(MaSP)) AS INT)) "
                    + "FROM SanPham WHERE MaSP LIKE 'SP%'";
            Object result = session.createNativeQuery(sql).uniqueResult();
            int next = (result != null) ? ((Number) result).intValue() + 1 : 1;
            return String.format("SP%02d", next);
        } catch (Exception e) {
            e.printStackTrace();
            return "SP01";
        }
    }

    // Thêm sản phẩm mới
    public boolean add(SanPham sp) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            try {
            // Cấp mã ngay khi lưu, khóa ngắn để tránh trùng giữa nhiều người thêm.
            Number max = (Number) session.createNativeQuery(
                "SELECT COALESCE(MAX(TRY_CAST(SUBSTRING(MaSP,3,20) AS BIGINT)),0) "
                + "FROM SanPham WITH (TABLOCKX,HOLDLOCK)").uniqueResult();
            sp.setMaSP(String.format("SP%02d", max.longValue() + 1));
            session.save(sp);
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
    public boolean update(SanPham sp) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            try {
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
    public boolean isSanPhamUsed(String maSP) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Object cntCombo = session.createNativeQuery("SELECT COUNT(*) FROM ChiTietCombo WHERE MaSP = :ma")
                    .setParameter("ma", maSP).uniqueResult();
            Object cntHD = session.createNativeQuery("SELECT COUNT(*) FROM ChiTietHoaDon WHERE MaSP = :ma")
                    .setParameter("ma", maSP).uniqueResult();
            int c1 = (cntCombo != null) ? ((Number) cntCombo).intValue() : 0;
            int c2 = (cntHD != null) ? ((Number) cntHD).intValue() : 0;
            return (c1 + c2) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return true;
        }
    }

    // Xóa sản phẩm
    public boolean delete(String maSP) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            try {
            SanPham sp = session.find(SanPham.class, maSP);
            if (sp != null) {
                session.delete(sp);
            }
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