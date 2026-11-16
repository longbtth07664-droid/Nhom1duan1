package repository;

import entity.Ghe;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import util.HibernateConfig;

import java.util.Collections;
import java.util.List;

public class GheRepository {

    // Lấy toàn bộ danh sách ghế của một phòng chiếu sắp xếp theo hàng và số ghế
    public List<Ghe> getAllByPhong(String maPhong) {
        if (maPhong == null || maPhong.trim().isEmpty()) {
            return Collections.emptyList();
        }
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT g FROM Ghe g JOIN FETCH g.loaiGhe JOIN FETCH g.phongChieu " +
                         "WHERE g.phongChieu.maPhong = :maPhong " +
                         "ORDER BY g.hangGhe ASC, g.soGhe ASC";
            return session.createQuery(hql, Ghe.class)
                    .setParameter("maPhong", maPhong.trim())
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // Tìm kiếm thông tin chi tiết một ghế theo mã ghế
    public Ghe getOne(Integer maGhe) {
        if (maGhe == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT g FROM Ghe g JOIN FETCH g.loaiGhe JOIN FETCH g.phongChieu WHERE g.maGhe = :id";
            return session.createQuery(hql, Ghe.class)
                    .setParameter("id", maGhe)
                    .uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // Kiểm tra xem vị trí hàng ghế và số ghế đã tồn tại trong phòng chiếu chưa
    public boolean existsSeat(String maPhong, String hangGhe, Integer soGhe, Integer excludeMaGhe) {
        if (maPhong == null || hangGhe == null || soGhe == null) return false;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT COUNT(g.maGhe) FROM Ghe g " +
                         "WHERE g.phongChieu.maPhong = :maPhong " +
                         "AND UPPER(g.hangGhe) = UPPER(:hang) " +
                         "AND g.soGhe = :so";
            if (excludeMaGhe != null) {
                hql += " AND g.maGhe <> :exId";
            }
            Query<Long> query = session.createQuery(hql, Long.class);
            query.setParameter("maPhong", maPhong.trim());
            query.setParameter("hang", hangGhe.trim().toUpperCase());
            query.setParameter("so", soGhe);
            if (excludeMaGhe != null) {
                query.setParameter("exId", excludeMaGhe);
            }
            Long count = query.uniqueResult();
            return count != null && count > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Kiểm tra ghế đã từng xuất hiện trong bảng Vé chưa để ngăn chặn lỗi khóa ngoại khi xóa
    public boolean isGheBooked(Integer maGhe) {
        if (maGhe == null) return false;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String sql = "SELECT COUNT(*) FROM Ve WHERE MaGhe = :ma";
            Object res = session.createNativeQuery(sql)
                    .setParameter("ma", maGhe)
                    .uniqueResult();
            return res != null && ((Number) res).intValue() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Thêm mới một ghế vào cơ sở dữ liệu
    public boolean add(Ghe ghe) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.persist(ghe);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // Cập nhật thông tin của ghế (loại ghế, trạng thái, giá)
    public boolean update(Ghe ghe) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.merge(ghe);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // Xóa một ghế theo mã ghế sau khi đã kiểm tra an toàn
    public boolean delete(Integer maGhe) {
        if (maGhe == null) return false;
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            Ghe ghe = session.get(Ghe.class, maGhe);
            if (ghe != null) {
                session.remove(ghe);
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
