package repository;

import entity.PhongChieu;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import util.HibernateConfig;

import java.util.Collections;
import java.util.List;

public class PhongChieuRepository {

    // Chuyển đổi an toàn từ Object/String sang Integer, trả null nếu không hợp lệ.
    private Integer parseId(Object val) {
        if (val == null) return null;
        if (val instanceof Number) return ((Number) val).intValue();
        try {
            String s = val.toString().trim();
            if (s.isEmpty()) return null;
            return Integer.parseInt(s);
        } catch (Exception e) {
            return null;
        }
    }

    // Lấy toàn bộ danh sách phòng chiếu, sắp xếp tăng dần theo mã phòng.
    public List<PhongChieu> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM PhongChieu ORDER BY maPhong ASC", PhongChieu.class)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // Tìm phòng chiếu theo mã phòng; trả null nếu không tìm thấy.
    public PhongChieu getById(Object maPhong) {
        Integer id = parseId(maPhong);
        if (id == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(PhongChieu.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // Overload nhận String maPhong, ủy quyền sang getById(Object).
    public PhongChieu getById(String maPhong) {
        return getById((Object) maPhong);
    }

    // Kiểm tra tên phòng đã tồn tại chưa; excludeMaPhong để bỏ qua phòng đang sửa.
    public boolean existsByTenPhong(String tenPhong, Object excludeMaPhong) {
        if (tenPhong == null || tenPhong.trim().isEmpty()) return false;
        Integer exId = parseId(excludeMaPhong);
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT COUNT(p.maPhong) FROM PhongChieu p WHERE LOWER(p.tenPhong) = LOWER(:ten)";
            if (exId != null) hql += " AND p.maPhong <> :ma";

            Query<Long> query = session.createQuery(hql, Long.class);
            query.setParameter("ten", tenPhong.trim());
            if (exId != null) query.setParameter("ma", exId);

            Long count = query.uniqueResult();
            return count != null && count > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Overload nhận String excludeMaPhong, ủy quyền sang existsByTenPhong(String, Object).
    public boolean existsByTenPhong(String tenPhong, String excludeMaPhong) {
        return existsByTenPhong(tenPhong, (Object) excludeMaPhong);
    }

    // Lưu phòng chiếu mới vào CSDL (maPhong tự tăng, đặt null trước khi insert).
    public boolean add(PhongChieu pc) {
        Transaction transaction = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            transaction = session.beginTransaction();
            pc.setMaPhong(null); // đảm bảo IDENTITY tự tăng
            session.persist(pc);
            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // Cập nhật thông tin phòng chiếu đã có vào CSDL, rollback nếu có lỗi.
    public boolean update(PhongChieu pc) {
        Transaction transaction = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            transaction = session.beginTransaction();
            session.merge(pc);
            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }
}
