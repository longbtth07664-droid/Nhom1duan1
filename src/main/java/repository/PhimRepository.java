package repository;

import entity.Phim;
import org.hibernate.Session;
import util.HibernateConfig;

import java.util.List;

public class PhimRepository {

    // 1. Lấy danh sách phim
    public List<Phim> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT DISTINCT p FROM Phim p LEFT JOIN FETCH p.theLoais LEFT JOIN FETCH p.dinhDangs ORDER BY p.maPhim",
                    Phim.class
            ).list();
        }
    }

    // 2. Lấy 1 phim theo mã (Integer)
    public Phim getOne(Integer maPhim) {
        if (maPhim == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT p FROM Phim p LEFT JOIN FETCH p.theLoais LEFT JOIN FETCH p.dinhDangs WHERE p.maPhim = :id",
                    Phim.class
            ).setParameter("id", maPhim).uniqueResult();
        }
    }

    // Overload nhận chuỗi mã phim từ Servlet
    public Phim getOne(String maPhimStr) {
        if (maPhimStr == null || maPhimStr.trim().isEmpty()) return null;
        try {
            return getOne(Integer.parseInt(maPhimStr.trim()));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // 3. Thêm mới phim
    public boolean add(Phim phim) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            session.getTransaction().begin();
            session.save(phim);
            session.getTransaction().commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 4. Cập nhật phim
    public boolean update(Phim phim) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            session.getTransaction().begin();
            session.merge(phim);
            session.getTransaction().commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 5. Tìm kiếm phim theo từ khóa (Mã/Tên/Đạo diễn) và lọc theo Thể loại
    public List<Phim> search(String keyword, String maTheLoai,String trangThai) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            StringBuilder hql = new StringBuilder(
                    "SELECT DISTINCT p FROM Phim p LEFT JOIN FETCH p.theLoais LEFT JOIN FETCH p.dinhDangs WHERE 1=1"
            );

            Integer numKw = null;
            if (keyword != null && !keyword.trim().isEmpty()) {
                try {
                    numKw = Integer.parseInt(keyword.trim());
                    hql.append(" AND (p.maPhim = :numKw OR LOWER(p.tenPhim) LIKE :kw OR LOWER(p.daoDien) LIKE :kw)");
                } catch (NumberFormatException e) {
                    hql.append(" AND (LOWER(p.tenPhim) LIKE :kw OR LOWER(p.daoDien) LIKE :kw)");
                }
            }

            Integer intTheLoai = null;
            if (maTheLoai != null && !maTheLoai.trim().isEmpty() && !"Tất cả".equalsIgnoreCase(maTheLoai)) {
                try {
                    intTheLoai = Integer.parseInt(maTheLoai.trim());
                    hql.append(" AND p.maPhim IN (SELECT p2.maPhim FROM Phim p2 JOIN p2.theLoais tl2 WHERE tl2.maTheLoai = :maTL)");
                } catch (NumberFormatException e) {
                    // bỏ qua nếu tham số không hợp lệ
                }
            }

            if (trangThai != null && !trangThai.trim().isEmpty() && !"Tất cả".equalsIgnoreCase(trangThai)) {
                hql.append(" AND p.trangThai = :trangThai");
            }

            hql.append(" ORDER BY p.maPhim");

            var query = session.createQuery(hql.toString(), Phim.class);

            if (keyword != null && !keyword.trim().isEmpty()) {
                query.setParameter("kw", "%" + keyword.trim().toLowerCase() + "%");
                if (numKw != null) {
                    query.setParameter("numKw", numKw);
                }
            }
            if (intTheLoai != null) {
                query.setParameter("maTL", intTheLoai);
            }

            if (trangThai != null && !trangThai.trim().isEmpty() && !"Tất cả".equalsIgnoreCase(trangThai)) {
                query.setParameter("trangThai", trangThai.trim());
            }

            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return getAll();
        }
    }

    // =========================================================================
    // [PHÂN TRANG - BACKEND] 1. Lấy danh sách phim theo trang (kết hợp tìm kiếm & lọc thể loại)
    // - page: Số trang cần lấy (bắt đầu từ 1)
    // - pageSize: Số lượng phim trên mỗi trang
    // =========================================================================
    public List<Phim> searchPaged(String keyword, String maTheLoai, String trangThai, int page, int pageSize) {
        List<Phim> all = search(keyword, maTheLoai, trangThai);
        if (all == null || all.isEmpty()) return java.util.Collections.emptyList();

        int fromIndex = (page - 1) * pageSize;
        if (fromIndex >= all.size()) return java.util.Collections.emptyList();

        int toIndex = Math.min(fromIndex + pageSize, all.size());
        return all.subList(fromIndex, toIndex);
    }

    // =========================================================================
    // [PHÂN TRANG - BACKEND] 2. Đếm tổng số lượng phim thỏa mãn điều kiện tìm kiếm/lọc
    // =========================================================================
    public int countSearch(String keyword, String maTheLoai, String trangThai) {
        List<Phim> all = search(keyword, maTheLoai, trangThai);
        return all != null ? all.size() : 0;
    }
}
