package repository;

import entity.LoaiPhong;
import org.hibernate.Session;
import org.hibernate.Transaction;
import util.HibernateConfig;

import java.util.Collections;
import java.util.List;

public class LoaiPhongRepository {

    // Lấy toàn bộ danh sách loại phòng từ cơ sở dữ liệu
    public List<LoaiPhong> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM LoaiPhong ORDER BY maLoaiPhong", LoaiPhong.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // Tìm kiếm 1 loại phòng theo mã loại phòng
    public LoaiPhong getOne(String maLoaiPhong) {
        if (maLoaiPhong == null || maLoaiPhong.trim().isEmpty()) {
            return null;
        }
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.find(LoaiPhong.class, maLoaiPhong.trim());
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // Thêm mới một loại phòng vào cơ sở dữ liệu
    public boolean add(LoaiPhong lp) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.persist(lp);
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

    // Cập nhật thông tin của một loại phòng
    public boolean update(LoaiPhong lp) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.merge(lp);
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

    // Xóa một loại phòng theo mã loại phòng
    public boolean delete(String maLoaiPhong) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            LoaiPhong lp = session.find(LoaiPhong.class, maLoaiPhong.trim());
            if (lp != null) {
                session.remove(lp);
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

    // Kiểm tra xem loại phòng có đang được phòng chiếu nào sử dụng không
    public boolean isLoaiPhongUsed(String maLoaiPhong) {
        if (maLoaiPhong == null || maLoaiPhong.trim().isEmpty()) {
            return false;
        }
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            LoaiPhong lp = session.find(LoaiPhong.class, maLoaiPhong.trim());
            String ten = lp != null ? lp.getTenLoaiPhong() : "";

            Long count = session.createQuery(
                    "SELECT COUNT(p) FROM PhongChieu p WHERE p.loaiPhong = :ma OR p.loaiPhong = :ten",
                    Long.class
            ).setParameter("ma", maLoaiPhong.trim())
             .setParameter("ten", ten)
             .getSingleResult();

            return count != null && count > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
