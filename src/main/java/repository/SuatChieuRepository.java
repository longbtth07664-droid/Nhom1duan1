package repository;

import entity.SuatChieu;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import util.HibernateConfig;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class SuatChieuRepository {

    public List<SuatChieu> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM SuatChieu sc ORDER BY sc.ngayChieu DESC, sc.gioBatDau ASC", SuatChieu.class)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public List<SuatChieu> filter(Object maPhim, Object maPhong, String dinhDang, String trangThai, LocalDate tuNgay, LocalDate denNgay, String keyword) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            StringBuilder hql = new StringBuilder("FROM SuatChieu sc WHERE 1=1 ");

            Integer pId = parseId(maPhim);
            String pcId = (maPhong != null && !maPhong.toString().trim().isEmpty()) ? maPhong.toString().trim() : null;

            if (pId != null) {
                hql.append("AND sc.phim.maPhim = :maPhim ");
            }
            if (pcId != null) {
                hql.append("AND sc.phongChieu.maPhong = :maPhong ");
            }
            if (dinhDang != null && !dinhDang.trim().isEmpty()) {
                hql.append("AND sc.dinhDang = :dinhDang ");
            }
            if (trangThai != null && !trangThai.trim().isEmpty()) {
                hql.append("AND sc.trangThai = :trangThai ");
            }
            if (tuNgay != null) {
                hql.append("AND sc.ngayChieu >= :tuNgay ");
            }
            if (denNgay != null) {
                hql.append("AND sc.ngayChieu <= :denNgay ");
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                hql.append("AND (LOWER(sc.phim.tenPhim) LIKE :kw OR LOWER(sc.phongChieu.tenPhong) LIKE :kw) ");
            }

            hql.append("ORDER BY sc.ngayChieu DESC, sc.gioBatDau ASC");

            Query<SuatChieu> query = session.createQuery(hql.toString(), SuatChieu.class);

            if (pId != null) query.setParameter("maPhim", pId);
            if (pcId != null) query.setParameter("maPhong", pcId);
            if (dinhDang != null && !dinhDang.trim().isEmpty()) query.setParameter("dinhDang", dinhDang.trim());
            if (trangThai != null && !trangThai.trim().isEmpty()) query.setParameter("trangThai", trangThai.trim());
            if (tuNgay != null) query.setParameter("tuNgay", tuNgay);
            if (denNgay != null) query.setParameter("denNgay", denNgay);
            if (keyword != null && !keyword.trim().isEmpty()) query.setParameter("kw", "%" + keyword.trim().toLowerCase() + "%");

            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public SuatChieu getOne(Object maSuat) {
        if (maSuat == null) return null;
        Integer id = parseId(maSuat);
        if (id == null) return null;

        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(SuatChieu.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public boolean add(SuatChieu suatChieu) {
        if (suatChieu == null) return false;
        // Reset maSuat de Hibernate sinh IDENTITY
        suatChieu.setMaSuat(null);
        if (suatChieu.getTrangThai() == null || suatChieu.getTrangThai().trim().isEmpty()) {
            suatChieu.setTrangThai("Đang mở bán");
        }
        if (suatChieu.getGiaVeCoBan() == null) {
            suatChieu.setGiaVeCoBan(BigDecimal.valueOf(80000));
        }

        Transaction transaction = null;
        Session session = null;
        try {
            session = HibernateConfig.getFACTORY().openSession();
            transaction = session.beginTransaction();
            session.persist(suatChieu);
            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                try {
                    transaction.rollback();
                } catch (Exception ignored) {}
            }
            e.printStackTrace();
            return false;
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    public boolean update(SuatChieu suatChieu) {
        if (suatChieu == null || suatChieu.getMaSuat() == null) return false;
        if (suatChieu.getTrangThai() == null || suatChieu.getTrangThai().trim().isEmpty()) {
            suatChieu.setTrangThai("Đang mở bán");
        }
        if (suatChieu.getGiaVeCoBan() == null) {
            suatChieu.setGiaVeCoBan(BigDecimal.valueOf(80000));
        }

        Transaction transaction = null;
        Session session = null;
        try {
            session = HibernateConfig.getFACTORY().openSession();
            transaction = session.beginTransaction();
            session.merge(suatChieu);
            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                try {
                    transaction.rollback();
                } catch (Exception ignored) {}
            }
            e.printStackTrace();
            return false;
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    public boolean cancel(Integer maSuat, String lyDoHuy) {
        if (maSuat == null) return false;
        Transaction transaction = null;
        Session session = null;
        try {
            session = HibernateConfig.getFACTORY().openSession();
            transaction = session.beginTransaction();
            SuatChieu sc = session.get(SuatChieu.class, maSuat);
            if (sc != null) {
                sc.setTrangThai("Đã hủy");
                sc.setLyDoHuy(lyDoHuy != null && !lyDoHuy.trim().isEmpty() ? lyDoHuy.trim() : "Quản lý hủy suất");
                session.merge(sc);
                transaction.commit();
                return true;
            }
            return false;
        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                try {
                    transaction.rollback();
                } catch (Exception ignored) {}
            }
            e.printStackTrace();
            return false;
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    public boolean checkTrungLich(Object maPhong, LocalDate ngayChieu, LocalTime batDau, LocalTime ketThuc, Integer maSuatIgnore) {
        if (maPhong == null || ngayChieu == null || batDau == null || ketThuc == null) return false;
        String pcId = maPhong.toString().trim();
        if (pcId.isEmpty()) return false;

        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "FROM SuatChieu sc WHERE sc.phongChieu.maPhong = :maPhong " +
                    "AND sc.ngayChieu = :ngayChieu " +
                    "AND (sc.trangThai IS NULL OR sc.trangThai <> 'Đã hủy')";

            if (maSuatIgnore != null) {
                hql += " AND sc.maSuat <> :maSuatIgnore";
            }

            Query<SuatChieu> query = session.createQuery(hql, SuatChieu.class);
            query.setParameter("maPhong", pcId);
            query.setParameter("ngayChieu", ngayChieu);

            if (maSuatIgnore != null) {
                query.setParameter("maSuatIgnore", maSuatIgnore);
            }

            List<SuatChieu> list = query.getResultList();
            for (SuatChieu sc : list) {
                LocalTime sBatDau = sc.getGioBatDau();
                LocalTime sKetThuc = sc.getGioKetThuc();
                if (sBatDau != null && sKetThuc != null) {
                    // Hai khoảng thời gian [batDau, ketThuc] và [sBatDau, sKetThuc] bị giao nhau (xung đột) khi:
                    // batDau < sKetThuc VÀ ketThuc > sBatDau
                    if (batDau.isBefore(sKetThuc) && ketThuc.isAfter(sBatDau)) {
                        return true; // Phát hiện trùng lịch chiếu trong cùng phòng!
                    }
                }
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Integer parseId(Object val) {
        if (val == null) return null;
        if (val instanceof Integer) return (Integer) val;
        try {
            return Integer.parseInt(val.toString().trim());
        } catch (Exception e) {
            return null;
        }
    }

    // Lấy tất cả các suất chiếu đang mở bán trong ngày (phục vụ màn hình Bán vé POS)
    public List<SuatChieu> getByNgay(LocalDate ngayChieu) {
        if (ngayChieu == null) return new ArrayList<>();
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "FROM SuatChieu sc " +
                    "WHERE sc.ngayChieu = :ngayChieu " +
                    "AND (sc.trangThai IS NULL OR sc.trangThai <> 'Đã hủy') " +
                    "ORDER BY sc.gioBatDau ASC";
            return session.createQuery(hql, SuatChieu.class)
                    .setParameter("ngayChieu", ngayChieu)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // Lấy danh sách suất chiếu của 1 phim trong 1 ngày cụ thể (phục vụ màn hình Bán vé POS)
    public List<SuatChieu> getByPhimVaNgay(Integer maPhim, LocalDate ngayChieu) {
        if (maPhim == null || ngayChieu == null) return new ArrayList<>();
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String hql = "FROM SuatChieu sc WHERE sc.phim.maPhim = :maPhim " +
                    "AND sc.ngayChieu = :ngayChieu " +
                    "AND sc.trangThai <> 'Đã hủy' " +
                    "ORDER BY sc.gioBatDau ASC";
            return session.createQuery(hql, SuatChieu.class)
                    .setParameter("maPhim", maPhim)
                    .setParameter("ngayChieu", ngayChieu)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // Lấy danh sách ID các ghế đã được bán trong 1 suất chiếu (để hiển thị trạng thái 'Đã bán')
    public List<Integer> getBookedSeatIds(Integer maSuat) {
        if (maSuat == null) return new ArrayList<>();
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            String sql = "SELECT MaGhe FROM Ve WHERE MaSuat = :maSuat AND (TrangThai IS NULL OR TrangThai <> N'Đã hủy')";
            List<?> list = session.createNativeQuery(sql)
                    .setParameter("maSuat", maSuat)
                    .getResultList();
            List<Integer> seatIds = new ArrayList<>();
            for (Object obj : list) {
                if (obj != null) {
                    seatIds.add(((Number) obj).intValue());
                }
            }
            return seatIds;
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
}
