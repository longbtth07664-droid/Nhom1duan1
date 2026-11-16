package repository;

import entity.TheLoai;
import org.hibernate.Session;
import util.HibernateConfig;

import java.util.List;

public class TheLoaiRepository {

    public List<TheLoai> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM TheLoai ORDER BY maTheLoai", TheLoai.class).list();
        }
    }

    public TheLoai getOne(Integer maTheLoai) {
        if (maTheLoai == null) return null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.find(TheLoai.class, maTheLoai);
        }
    }

    public TheLoai getOne(String maTheLoai) {
        if (maTheLoai == null || maTheLoai.trim().isEmpty()) return null;
        try {
            return getOne(Integer.parseInt(maTheLoai.trim()));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public boolean add(TheLoai tl) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            session.getTransaction().begin();
            session.save(tl);
            session.getTransaction().commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean update(TheLoai tl) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            session.getTransaction().begin();
            session.merge(tl);
            session.getTransaction().commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static void main(String[] args) {
        System.out.println(new TheLoaiRepository().getAll().size());
    }
}
