
package repository;

import entity.PhongChieu;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import util.HibernateConfig;

import java.util.List;

public class PhongChieuRepository {

    // Lấy toàn bộ danh sách phòng chiếu sắp xếp tăng dần theo mã phòng
    public List<PhongChieu> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            Query<PhongChieu> query = session.createQuery(
                    "FROM PhongChieu ORDER BY maPhong ASC",
                    PhongChieu.class
            );

            return query.getResultList();
        }
    }

    // Tìm kiếm thông tin phòng chiếu theo mã phòng
    public PhongChieu getById(String maPhong) {
        if (maPhong == null || maPhong.trim().isEmpty()) {
            return null;
        }

        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(PhongChieu.class, maPhong.trim());
        }
    }

    // Kiểm tra tên phòng đã tồn tại chưa (loại trừ mã phòng đang cập nhật)
    public boolean existsByTenPhong(String tenPhong, String excludeMaPhong) {

        if (tenPhong == null || tenPhong.trim().isEmpty()) {
            return false;
        }

        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            String hql = "SELECT COUNT(p.maPhong) " +
                    "FROM PhongChieu p " +
                    "WHERE LOWER(p.tenPhong) = LOWER(:ten)";

            if (excludeMaPhong != null && !excludeMaPhong.trim().isEmpty()) {
                hql += " AND p.maPhong <> :ma";
            }

            Query<Long> query = session.createQuery(hql, Long.class);
            query.setParameter("ten", tenPhong.trim());

            if (excludeMaPhong != null && !excludeMaPhong.trim().isEmpty()) {
                query.setParameter("ma", excludeMaPhong.trim());
            }

            Long count = query.uniqueResult();

            return count != null && count > 0;
        }
    }

    // Thêm mới một phòng chiếu vào cơ sở dữ liệu
    public boolean add(PhongChieu pc) {

        Transaction transaction = null;

        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            transaction = session.beginTransaction();

            session.persist(pc);

            transaction.commit();

            return true;

        } catch (Exception e) {

            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }

            e.printStackTrace();
            return false;
        }
    }

    // Cập nhật thông tin phòng chiếu đã có
    public boolean update(PhongChieu pc) {

        Transaction transaction = null;

        try (Session session = HibernateConfig.getFACTORY().openSession()) {

            transaction = session.beginTransaction();

            session.merge(pc);

            transaction.commit();

            return true;

        } catch (Exception e) {

            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }

            e.printStackTrace();
            return false;
        }
    }
}
