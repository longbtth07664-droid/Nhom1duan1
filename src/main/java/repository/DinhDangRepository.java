package repository;

import entity.DinhDang;
import org.hibernate.Session;
import org.hibernate.Transaction;
import util.HibernateConfig;

import java.util.ArrayList;
import java.util.List;

public class DinhDangRepository {

    public List<DinhDang> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM DinhDang ORDER BY maDinhDang", DinhDang.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return java.util.Collections.emptyList();
        }
    }

    public DinhDang getOne(Integer id) {
        if (id == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(DinhDang.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public DinhDang getOne(String idStr) {
        if (idStr == null || idStr.trim().isEmpty()) return null;
        try {
            return getOne(Integer.parseInt(idStr.trim()));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * Lấy danh sách định dạng mà một Phòng chiếu hỗ trợ (từ bảng Phong_DinhDang)
     */
    public List<DinhDang> getByPhong(Integer maPhong) {
        if (maPhong == null) return java.util.Collections.emptyList();
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String sql = "SELECT dd.* FROM DinhDang dd " +
                    "INNER JOIN Phong_DinhDang pdd ON dd.MaDinhDang = pdd.MaDinhDang " +
                    "WHERE pdd.MaPhong = :maPhong ORDER BY dd.MaDinhDang";
            return session.createNativeQuery(sql, DinhDang.class)
                    .setParameter("maPhong", maPhong)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return java.util.Collections.emptyList();
        }
    }

    /**
     * Lấy danh sách định dạng mà một Phim phát hành (từ bảng Phim_DinhDang)
     */
    public List<DinhDang> getByPhim(Integer maPhim) {
        if (maPhim == null) return java.util.Collections.emptyList();
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String sql = "SELECT dd.* FROM DinhDang dd " +
                    "INNER JOIN Phim_DinhDang fdd ON dd.MaDinhDang = fdd.MaDinhDang " +
                    "WHERE fdd.MaPhim = :maPhim ORDER BY dd.MaDinhDang";
            return session.createNativeQuery(sql, DinhDang.class)
                    .setParameter("maPhim", maPhim)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return java.util.Collections.emptyList();
        }
    }

    /**
     * Lưu danh sách định dạng hỗ trợ của Phòng chiếu vào bảng Phong_DinhDang
     */
    public void savePhongDinhDang(Integer maPhong, List<Integer> dinhDangIds) {
        if (maPhong == null) return;
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.createNativeMutationQuery("DELETE FROM Phong_DinhDang WHERE MaPhong = :maPhong")
                    .setParameter("maPhong", maPhong)
                    .executeUpdate();
            if (dinhDangIds != null) {
                for (Integer ddId : dinhDangIds) {
                    if (ddId != null) {
                        session.createNativeMutationQuery("INSERT INTO Phong_DinhDang (MaPhong, MaDinhDang) VALUES (:mp, :mdd)")
                                .setParameter("mp", maPhong)
                                .setParameter("mdd", ddId)
                                .executeUpdate();
                    }
                }
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
        }
    }

    /**
     * Lấy phần GIAO (trùng nhau) giữa định dạng Phim có và định dạng Phòng hỗ trợ.
     */
    public List<DinhDang> getCommonFormats(Integer maPhim, Integer maPhong) {
        if (maPhim == null && maPhong == null) return getAll();
        if (maPhim != null && maPhong == null) {
            List<DinhDang> byPhim = getByPhim(maPhim);
            return byPhim.isEmpty() ? getAll() : byPhim;
        }
        if (maPhim == null) {
            List<DinhDang> byPhong = getByPhong(maPhong);
            return byPhong.isEmpty() ? getAll() : byPhong;
        }

        List<DinhDang> byPhim = getByPhim(maPhim);
        List<DinhDang> byPhong = getByPhong(maPhong);
        if (byPhim.isEmpty() && byPhong.isEmpty()) return getAll();
        if (byPhim.isEmpty()) return byPhong;
        if (byPhong.isEmpty()) return byPhim;

        List<DinhDang> common = new ArrayList<>();
        for (DinhDang df : byPhim) {
            for (DinhDang dp : byPhong) {
                if (df.getMaDinhDang() != null && df.getMaDinhDang().equals(dp.getMaDinhDang())) {
                    common.add(df);
                    break;
                }
            }
        }
        return common;
    }
}
