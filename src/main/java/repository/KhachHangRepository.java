package repository;

import entity.KhachHang;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import util.HibernateConfig;

import java.util.Collections;
import java.util.List;

public class KhachHangRepository {

    // Lấy toàn bộ danh sách khách hàng, sắp xếp tăng dần theo mã khách hàng.
    public List<KhachHang> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM KhachHang ORDER BY maKH ASC", KhachHang.class)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // Tìm kiếm khách hàng theo họ tên, SĐT hoặc mã; hỗ trợ phân trang.
    public List<KhachHang> search(String keyword, int page, int pageSize) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "FROM KhachHang k ";
            if (keyword != null && !keyword.trim().isEmpty()) {
                hql += "WHERE LOWER(k.hoTen) LIKE :kw OR k.sdt LIKE :kw OR LOWER(k.maKH) LIKE :kw ";
            }
            hql += "ORDER BY k.maKH ASC";

            Query<KhachHang> query = session.createQuery(hql, KhachHang.class);
            if (keyword != null && !keyword.trim().isEmpty()) {
                query.setParameter("kw", "%" + keyword.trim().toLowerCase() + "%");
            }
            query.setFirstResult((page - 1) * pageSize);
            query.setMaxResults(pageSize);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // Đếm số khách hàng thỏa điều kiện keyword để tính tổng trang phân trang.
    public int countSearch(String keyword) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT COUNT(k) FROM KhachHang k ";
            if (keyword != null && !keyword.trim().isEmpty()) {
                hql += "WHERE LOWER(k.hoTen) LIKE :kw OR k.sdt LIKE :kw OR LOWER(k.maKH) LIKE :kw";
            }
            Query<Long> query = session.createQuery(hql, Long.class);
            if (keyword != null && !keyword.trim().isEmpty()) {
                query.setParameter("kw", "%" + keyword.trim().toLowerCase() + "%");
            }
            Long count = query.uniqueResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // Đếm tổng số khách hàng hiện có trong hệ thống (không lọc keyword).
    public int count() {
        return countSearch(null);
    }

    // Tìm thông tin chi tiết một khách hàng theo mã; trả null nếu không tìm thấy.
    public KhachHang getById(String maKH) {
        if (maKH == null || maKH.trim().isEmpty()) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(KhachHang.class, maKH.trim());
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // Kiểm tra SĐT đã tồn tại chưa; excludeMaKH để bỏ qua khách hàng đang sửa.
    public boolean existsBySdt(String sdt, String excludeMaKH) {
        if (sdt == null || sdt.trim().isEmpty()) return false;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT COUNT(k) FROM KhachHang k WHERE k.sdt = :sdt";
            if (excludeMaKH != null && !excludeMaKH.trim().isEmpty()) hql += " AND k.maKH <> :ma";

            Query<Long> query = session.createQuery(hql, Long.class);
            query.setParameter("sdt", sdt.trim());
            if (excludeMaKH != null && !excludeMaKH.trim().isEmpty()) {
                query.setParameter("ma", excludeMaKH.trim());
            }
            Long count = query.uniqueResult();
            return count != null && count > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Lưu khách hàng mới vào CSDL trong transaction, rollback nếu có lỗi.
    public boolean add(KhachHang kh) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.persist(kh);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // Cập nhật thông tin khách hàng vào CSDL, rollback nếu có lỗi.
    public boolean update(KhachHang kh) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.merge(kh);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // Xóa khách hàng theo mã khỏi CSDL, rollback nếu có lỗi.
    public boolean delete(String maKH) {
        if (maKH == null || maKH.trim().isEmpty()) return false;
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            KhachHang kh = session.get(KhachHang.class, maKH.trim());
            if (kh != null) session.remove(kh);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        }
    }
}
