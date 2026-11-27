package repository;

import entity.NhanVien;
import org.hibernate.Session;
import org.hibernate.Transaction;
import util.HibernateConfig;

import java.util.List;

public class NhanVienRepository {

    // Lấy toàn bộ danh sách nhân viên
    public List<NhanVien> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM NhanVien", NhanVien.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // Lấy thông tin 1 nhân viên theo ID (Dùng cho chức năng Sửa / Chi tiết)
    public NhanVien getOne(Integer id) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.find(NhanVien.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // Thêm mới nhân viên
    public void add(NhanVien nhanVien) {
        Transaction transaction = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            transaction = session.beginTransaction();
            session.persist(nhanVien); // Hoặc session.save(nhanVien);
            transaction.commit();
        } catch (Exception e) {
            if (transaction != null && transaction.getStatus().canRollback()) {
                try {
                    transaction.rollback();
                } catch (Exception rbEx) {
                    rbEx.printStackTrace();
                }
            }
            e.printStackTrace();
        }
    }

    // Cập nhật thông tin nhân viên
    public void update(NhanVien nhanVien) {
        Transaction transaction = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            transaction = session.beginTransaction();
            session.merge(nhanVien);
            transaction.commit();
        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
        }
    }

    // Xóa mềm: Chuyển trạng thái thành "Nghỉ việc"
    public void updateTrangThaiNghiViec(Integer id) {
        Transaction transaction = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            transaction = session.beginTransaction();
            NhanVien nv = session.find(NhanVien.class, id);
            if (nv != null) {
                nv.setTrangThai("Nghỉ việc");
                session.merge(nv);
            }
            transaction.commit();
        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
        }
    }


    public String validateFormat(String cccd, String email, String soDienThoai) {
        String c = cccd != null ? cccd.trim() : "";
        String e = email != null ? email.trim() : "";
        String s = soDienThoai != null ? soDienThoai.trim() : "";

        // Bắt buộc nhập CCCD
        if (c.isEmpty()) {
            return "Vui lòng nhập CCCD!";
        }

        // CCCD: chỉ gồm chữ số, đúng 12 số, bắt đầu bằng 0 (nếu có nhập)
        if (!c.isEmpty() && !c.matches("0\\d{11}")) {
            return "CCCD chỉ được chứa chữ số, gồm 12 số và bắt đầu bằng 0!";
        }

        // SĐT: chỉ gồm chữ số, 10 - 11 số, bắt đầu bằng 0 (nếu có nhập)
        if (!s.isEmpty() && !s.matches("0\\d{9,10}")) {
            return "Số điện thoại chỉ được chứa chữ số (10 - 11 số, bắt đầu bằng 0)!";
        }

        // Email: đúng định dạng chuẩn (nếu có nhập)
        if (!e.isEmpty() && !e.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            return "Email không đúng định dạng (ví dụ: ten@gmail.com)!";
        }

        return null;
    }

    public static void main(String[] args) {
        System.out.println(new NhanVienRepository().getAll());
    }
}