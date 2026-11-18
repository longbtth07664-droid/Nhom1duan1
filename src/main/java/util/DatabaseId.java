package util;

/** Chuyển mã từ form/URL sang khóa INT của SQL Server. */
public final class DatabaseId {
    private DatabaseId() { }

    public static Integer parse(String value) {
        try {
            int id = Integer.parseInt(value == null ? "" : value.trim());
            if (id > 0) return id;
        } catch (NumberFormatException ignored) {
            // Báo lỗi đầu vào thay vì gửi mã không hợp lệ xuống SQL Server.
        }
        throw new IllegalArgumentException("Mã phải là số nguyên dương.");
    }
}
