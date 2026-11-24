package repository;

import entity.Ghe;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import util.HibernateConfig;

import java.util.Collections;
import java.util.List;

public class GheRepository {

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

    // Lấy tất cả ghế của một phòng, sắp xếp theo hàng và số ghế tăng dần.
    public List<Ghe> getAllByPhong(Object maPhong) {
        Integer id = parseId(maPhong);
        if (id == null) return Collections.emptyList();
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT g FROM Ghe g JOIN FETCH g.loaiGhe JOIN FETCH g.phongChieu " +
                         "WHERE g.phongChieu.maPhong = :maPhong " +
                         "ORDER BY g.hangGhe ASC, g.soGhe ASC";
            return session.createQuery(hql, Ghe.class)
                    .setParameter("maPhong", id)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // Overload nhận String maPhong, ủy quyền sang getAllByPhong(Object).
    public List<Ghe> getAllByPhong(String maPhong) {
        return getAllByPhong((Object) maPhong);
    }

    // Lấy thông tin chi tiết một ghế theo mã ghế, kèm loại ghế và phòng chiếu.
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

    // Kiểm tra vị trí (hàng + số) đã tồn tại trong phòng chưa; excludeMaGhe để bỏ qua ghế đang sửa.
    public boolean existsSeat(Object maPhong, String hangGhe, Integer soGhe, Integer excludeMaGhe) {
        Integer id = parseId(maPhong);
        if (id == null || hangGhe == null || soGhe == null) return false;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "SELECT COUNT(g.maGhe) FROM Ghe g " +
                         "WHERE g.phongChieu.maPhong = :maPhong " +
                         "AND UPPER(g.hangGhe) = UPPER(:hang) " +
                         "AND g.soGhe = :so";
            if (excludeMaGhe != null) hql += " AND g.maGhe <> :exId";

            Query<Long> query = session.createQuery(hql, Long.class);
            query.setParameter("maPhong", id);
            query.setParameter("hang", hangGhe.trim().toUpperCase());
            query.setParameter("so", soGhe);
            if (excludeMaGhe != null) query.setParameter("exId", excludeMaGhe);

            Long count = query.uniqueResult();
            return count != null && count > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Overload nhận String maPhong, ủy quyền sang existsSeat(Object,...).
    public boolean existsSeat(String maPhong, String hangGhe, Integer soGhe, Integer excludeMaGhe) {
        return existsSeat((Object) maPhong, hangGhe, soGhe, excludeMaGhe);
    }

    // Kiểm tra ghế đã được đặt vé chưa để ngăn xóa khi còn dữ liệu liên quan.
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

    // Lưu một ghế mới vào CSDL trong transaction, rollback nếu có lỗi.
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

    // Cập nhật thông tin ghế (loại ghế, trạng thái) vào CSDL, rollback nếu có lỗi.
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

    // Xóa ghế theo mã khỏi CSDL, rollback nếu có lỗi.
    public boolean delete(Integer maGhe) {
        if (maGhe == null) return false;
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            Ghe ghe = session.get(Ghe.class, maGhe);
            if (ghe != null) session.remove(ghe);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        }
    }
}
