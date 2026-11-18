package util;

import org.hibernate.Session;
import java.util.List;

public class CheckDBData {
    public static void main(String[] args) {
        try (Session s = HibernateConfig.getFACTORY().openSession()) {
            List list = s.createNativeQuery("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'").getResultList();
            for (Object row : list) {
                System.out.println("TABLE: " + row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
