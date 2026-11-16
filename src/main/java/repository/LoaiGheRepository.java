package repository;

import entity.LoaiGhe;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import util.HibernateConfig;

import java.util.Collections;
import java.util.List;

public class LoaiGheRepository {

    // Lấy toàn bộ danh sách các loại ghế từ cơ sở dữ liệu sắp xếp theo mã
    public List<LoaiGhe> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM LoaiGhe ORDER BY maLoaiGhe ASC", LoaiGhe.class).getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // Tìm kiếm 1 loại ghế theo mã loại ghế
    public LoaiGhe getOne(Integer maLoaiGhe) {
        if (maLoaiGhe == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(LoaiGhe.class, maLoaiGhe);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // Kiểm tra tên loại ghế đã tồn tại chưa để tránh trùng lặp tên loại ghế
    public boolean existsByTen(String tenLoaiGhe, Integer excludeMa) {
        if (tenLoaiGhe == null || tenLoaiGhe.trim().isEmpty()) return false;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT COUNT(lg.maLoaiGhe) FROM LoaiGhe lg WHERE LOWER(lg.tenLoaiGhe) = LOWER(:ten)";
            if (excludeMa != null) {
                hql += " AND lg.maLoaiGhe <> :exId";
            }
            Query<Long> query = session.createQuery(hql, Long.class);
            query.setParameter("ten", tenLoaiGhe.trim());
            if (excludeMa != null) {
                query.setParameter("exId", excludeMa);
            }
            Long count = query.uniqueResult();
            return count != null && count > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Kiểm tra loại ghế có đang được ghế nào trong rạp sử dụng hay không
    public boolean isLoaiGheUsed(Integer maLoaiGhe) {
        if (maLoaiGhe == null) return false;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT COUNT(g.maGhe) FROM Ghe g WHERE g.loaiGhe.maLoaiGhe = :ma";
            Long count = session.createQuery(hql, Long.class)
                    .setParameter("ma", maLoaiGhe)
                    .uniqueResult();
            return count != null && count > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Thêm mới một loại ghế vào cơ sở dữ liệu
    public boolean add(LoaiGhe lg) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.persist(lg);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // Cập nhật thông tin loại ghế (tên loại ghế và tiền phụ thu)
    public boolean update(LoaiGhe lg) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.merge(lg);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // Xóa một loại ghế theo mã loại ghế sau khi đã kiểm tra an toàn
    public boolean delete(Integer maLoaiGhe) {
        if (maLoaiGhe == null) return false;
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            LoaiGhe lg = session.get(LoaiGhe.class, maLoaiGhe);
            if (lg != null) {
                session.remove(lg);
            }
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        }
    }
}
