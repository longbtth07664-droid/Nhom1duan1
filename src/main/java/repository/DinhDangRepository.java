package repository;

import entity.DinhDang;
import org.hibernate.Session;
import util.HibernateConfig;

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
}
