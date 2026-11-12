package repository;

import entity.TheLoai;
import org.hibernate.Session;
import org.hibernate.Transaction;
import util.HibernateConfig;

import java.util.List;

public class TheLoaiRepository {

    public List<TheLoai> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM TheLoai ORDER BY maTheLoai", TheLoai.class).list();
        }
    }

    public TheLoai getOne(String maTheLoai) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.find(TheLoai.class, maTheLoai);
        }
    }

    public boolean add(TheLoai tl) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.save(tl);
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

    public boolean update(TheLoai tl) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.merge(tl);
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

    public static void main(String[] args) {
        System.out.println(new TheLoaiRepository().getAll().size());
    }
}
