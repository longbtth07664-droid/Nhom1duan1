package repository;

import entity.ChiTietCombo;
import entity.Combo;
import org.hibernate.Session;
import org.hibernate.Transaction;
import util.HibernateConfig;

import java.util.ArrayList;
import java.util.List;

public class ComboRepository {

    // 1. Lấy toàn bộ danh sách Combo
    public List<Combo> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("SELECT c FROM Combo c ORDER BY c.maCombo", Combo.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // 2. Lấy 1 Combo theo MaCombo
    public Combo getOne(String maCombo) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.find(Combo.class, maCombo);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 3. Tìm kiếm Combo theo mã hoặc tên (và lọc theo trạng thái nếu có chọn)
    public List<Combo> search(String keyword, String trangThai) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            StringBuilder hql = new StringBuilder("SELECT c FROM Combo c WHERE 1=1");
            if (keyword != null && !keyword.trim().isEmpty()) {
                hql.append(" AND (c.maCombo LIKE :kw OR c.tenCombo LIKE :kw)");
            }
            if (trangThai != null && !trangThai.trim().isEmpty() && !"Tất cả".equals(trangThai)) {
                hql.append(" AND c.trangThai = :tt");
            }
            hql.append(" ORDER BY c.maCombo");

            var query = session.createQuery(hql.toString(), Combo.class);
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

    // 4. Tự động sinh mã Combo tiếp theo (VD: đã có CB01..CB10 -> trả về CB11)
    public String generateId() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String sql = "SELECT MAX(TRY_CAST(SUBSTRING(MaCombo, 3, LEN(MaCombo)) AS INT)) "
                    + "FROM Combo WHERE MaCombo LIKE 'CB%'";
            Object result = session.createNativeQuery(sql).uniqueResult();
            int next = (result != null) ? ((Number) result).intValue() + 1 : 1;
            return String.format("CB%02d", next);
        } catch (Exception e) {
            e.printStackTrace();
            return "CB01";
        }
    }

    // 5. Lấy danh sách sản phẩm bên trong 1 Combo (JOIN FETCH để tải sẵn SanPham trước khi đóng Session)
    public List<ChiTietCombo> getChiTiet(String maCombo) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT ct FROM ChiTietCombo ct "
                    + "JOIN FETCH ct.sanPham "
                    + "WHERE ct.maCombo = :ma ORDER BY ct.maSP";
            return session.createQuery(hql, ChiTietCombo.class)
                    .setParameter("ma", maCombo)
                    .list();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // 6. Thêm mới Combo cùng danh sách sản phẩm chi tiết (chung 1 Transaction)
    public boolean addComboVaChiTiet(Combo combo, List<ChiTietCombo> dsChiTiet) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.save(combo); // Hibernate 5.6 dùng save() giống TheLoaiRepository
            for (ChiTietCombo ct : dsChiTiet) {
                ct.setMaCombo(combo.getMaCombo());
                session.save(ct);
            }
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback(); // Lỗi thì hoàn tác toàn bộ
            }
            e.printStackTrace();
            return false;
        }
    }

    // 7. Cập nhật Combo và ghi lại danh sách chi tiết mới (chung 1 Transaction)
    public boolean updateComboVaChiTiet(Combo combo, List<ChiTietCombo> dsChiTiet) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.merge(combo); // Cập nhật thông tin Combo

            // Xóa hết chi tiết cũ rồi thêm lại chi tiết mới (Hibernate 5.6 dùng createQuery)
            session.createQuery("DELETE FROM ChiTietCombo ct WHERE ct.maCombo = :ma")
                    .setParameter("ma", combo.getMaCombo())
                    .executeUpdate();

            for (ChiTietCombo ct : dsChiTiet) {
                ct.setMaCombo(combo.getMaCombo());
                session.save(ct);
            }
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            e.printStackTrace();
            return false;
        }
    }

    // 8. Kiểm tra Combo đã từng xuất hiện trong ChiTietHoaDon chưa (tránh lỗi khóa ngoại khi xóa)
    public boolean isComboInHoaDon(String maCombo) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String sql = "SELECT COUNT(*) FROM ChiTietHoaDon WHERE MaCombo = :ma";
            Object result = session.createNativeQuery(sql)
                    .setParameter("ma", maCombo)
                    .uniqueResult();
            return result != null && ((Number) result).intValue() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 9. Xóa Combo (xóa ChiTietCombo trước rồi xóa Combo)
    public boolean delete(String maCombo) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            Combo combo = session.find(Combo.class, maCombo);
            if (combo != null) {
                session.createQuery("DELETE FROM ChiTietCombo ct WHERE ct.maCombo = :ma")
                        .setParameter("ma", maCombo)
                        .executeUpdate();
                session.delete(combo); // Hibernate 5.6 dùng delete()
            }
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            e.printStackTrace();
            return false;
        }
    }
}