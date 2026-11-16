package repository;

import entity.KhachHang;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import util.HibernateConfig;

import java.util.Collections;
import java.util.List;

public class KhachHangRepository {

    private static final int PAGE_SIZE = 5;

    // Lấy toàn bộ danh sách khách hàng (dùng cho phân trang)
    public List<KhachHang> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM KhachHang ORDER BY maKH ASC", KhachHang.class)
                    .getResultList();
        }
    }

    // Lấy 1 trang (5 bản ghi)
    public List<KhachHang> getPage(int page) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            List<KhachHang> all = getAll();
            int total = all.size();
            int start = (page - 1) * PAGE_SIZE;
            if (start >= total) return Collections.emptyList();
            int end = Math.min(start + PAGE_SIZE, total);
            return all.subList(start, end);
        }
    }

    // Đếm tổng số lượng khách hàng (tính tổng trang)
    public int count() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            Long count = session.createQuery("SELECT COUNT(k) FROM KhachHang k", Long.class)
                    .uniqueResult();
            return count != null ? count.intValue() : 0;
        }
    }

    // Tìm theo mã khách hàng
    public KhachHang getById(String maKH) {
        if (maKH == null || maKH.trim().isEmpty()) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(KhachHang.class, maKH.trim());
        }
    }

    // Kiểm tra số điện thoại đã tồn tại chưa (tránh trùng SDT)
    public boolean existsBySdt(String sdt, String excludeMaKH) {
        if (sdt == null || sdt.trim().isEmpty()) return false;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT COUNT(k) FROM KhachHang k WHERE k.sdt = :sdt";
            if (excludeMaKH != null && !excludeMaKH.trim().isEmpty()) {
                hql += " AND k.maKH <> :ma";
            }
            Query<Long> query = session.createQuery(hql, Long.class);
            query.setParameter("sdt", sdt.trim());
            if (excludeMaKH != null && !excludeMaKH.trim().isEmpty()) {
                query.setParameter("ma", excludeMaKH.trim());
            }
            Long count = query.uniqueResult();
            return count != null && count > 0;
        }
    }

    // Thêm khách hàng mới
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

    // Cập nhật khách hàng
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
}
