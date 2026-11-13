package repository;

import entity.Phim;
import org.hibernate.Session;
import org.hibernate.Transaction;
import util.HibernateConfig;

import java.util.List;

public class PhimRepository {

    public List<Phim> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT DISTINCT p FROM Phim p LEFT JOIN FETCH p.theLoais ORDER BY p.maPhim",
                    Phim.class
            ).list();
        }
    }

    public Phim getOne(String maPhim) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery(
                    "SELECT p FROM Phim p LEFT JOIN FETCH p.theLoais WHERE p.maPhim = :id",
                    Phim.class
            ).setParameter("id", maPhim).uniqueResult();
        }
    }

    public boolean add(Phim phim) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.save(phim);
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

    public boolean update(Phim phim) {
        Transaction tx = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            tx = session.beginTransaction();
            session.merge(phim);
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
}
